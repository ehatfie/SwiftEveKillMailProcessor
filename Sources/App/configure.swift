import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import Queues
import QueuesRedisDriver
import Collections

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    let _ = DatabaseConfigurationFactory.postgres(
        configuration: SQLPostgresConfiguration(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database",
            tls: .disable
        )
    )
    
    let dbConfig1 = DatabaseConfigurationFactory.postgres(
        configuration: SQLPostgresConfiguration(
            hostname: "localhost",
            port: SQLPostgresConfiguration.ianaPortNumber,
            username: "postgres",
            password: " ",
            database: "postgres",
            tls: .disable
        )
    )
    app.databases.use(dbConfig1, as: .psql)
    app.logger.logLevel = .info
    configureQueues(app)
    setupModels(app)
    app.views.use(.leaf)
    
    try app.queues.startInProcessJobs(on: .default)
    
//    try await app.queues.queue.dispatch(a
//        EmailJob.self,
//        .init(to: "foo@bar.com", message: "Hello World!")
//    )
    
    
    // register routes
    try routes(app)
}

func configureQueues(_ app: Application) {
    app.queues.use(.useQueueDriver())
    app.queues.add(EmailJob())
    app.queues.add(ModelJob())
}

func setupModels(_ app: Application) {
    app.migrations.add(ZKillmailModel.ModelMigration())
    app.migrations.add(ESIKillmailModel.ModelMigration())
    
    app.migrations.add(CharacterIdentifiersModel.ModelMigration())
    app.migrations.add(CorporationInfoModel.ModelMigration())
    app.migrations.add(AllianceInfoModel.ModelMigration())
}

func setupModelsAsync(_ app: Application) async {
    app.migrations.add(ZKillmailModel.ModelMigration())
}

struct Email: Codable {
    let to: String
    let message: String
}

struct EmailJob: AsyncJob {
    typealias Payload = Email

    func dequeue(_ context: QueueContext, _ payload: Email) async throws {
        // This is where you would send the email
        print("Email Job Dequeue")
        
        //while true {
            let response = try await context.application.client.get("https://redisq.zkillboard.com/listen.php?queueID=YourIdHere2q3")
            let decoder = JSONDecoder()
            
            let data = Data(buffer: response.body!, byteTransferStrategy: .automatic)
            do {
                let object = try decoder.decode(ZKillFeedResponseWrapper.self, from: data)
               // context.application.post
                print("email job got \(object.package.killID)")
                try await context.application.queues.queue.dispatch(
                    ModelJob.self,
                    object
                )
                //print("got object \(object)")
            } catch let err {
                print("Decode error \(err)")
            }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            try? context.application.queues.queue.dispatch(
                EmailJob.self,
                .init(to: "foo@bar.com", message: "Hello World!")
            ).wait()
        }

        //}
    }

    func error(_ context: QueueContext, _ error: Error, _ payload: Email) async throws {
        // If you don't want to handle errors you can simply return. You can also omit this function entirely.
        print("Emaiol job error")
    }
}

struct ModelJob: AsyncJob {
    typealias Payload = ZKillFeedResponseWrapper
    
    func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
        let model = ESIKillmailModel(data: payload.package.killmail)
        
        do {
            try await model.save(on: context.application.db)
            print("saved \(model.killmailId)")
        } catch let err {
            print("MJ error \(String(reflecting:err))")
        }
       
    }

    func error(_ context: QueueContext, _ error: Error, _ payload: Email) async throws {
        // If you don't want to handle errors you can simply return. You can also omit this function entirely.
        print("Model job error" + String(reflecting: error))
    }
}

struct CommandSig: CommandSignature {
    
}

struct SendEmailCommand: AsyncCommand {
    typealias Signature = CommandSig
    
    var help: String
    
    func run(using context: CommandContext, signature: Signature) async throws {
        try await context
                .application
                .queues
                .queue
                .dispatch(
                    EmailJob.self,
                    .init(to: "foo@bar.com", message: "Hello World")
                )
    }
}


class TestQueueDriver: QueuesDriver, @unchecked Sendable {
    var identifiers: Deque<JobIdentifier> = []
    var jobsDict: [JobIdentifier: JobData] = [:] //TreeDictionary<JobIdentifier, JobData> = TreeDictionary()
    
    func makeQueue(with context: Queues.QueueContext) -> Queue {
        QueueThing(context: context, driver: self)
    }
    
    /// Shuts down the driver
    func shutdown() {
        
    }
    
    /// Shut down the driver asynchronously. Helps avoid calling `.wait()`
    func asyncShutdown() async {
        
    }
    
}

extension Application.Queues.Provider {
    
    public static func useQueueDriver() -> Self {
        .init {
            $0.queues.use(custom: TestQueueDriver())
        }
    }
    
}

struct QueueThing {
    var context: QueueContext
    var driver: TestQueueDriver
}

extension QueueThing: AsyncQueue {
    
    func push(_ id: JobIdentifier) async throws {
        print("push \(id)")
        driver.identifiers.append(id)
    }
    
    func pop() async throws -> JobIdentifier? {
        guard !driver.identifiers.isEmpty else { return nil }
        return driver.identifiers.popFirst()
    }
    
    func clear(_ id: JobIdentifier) async throws {
        print("clear \(id)")
        self.driver.jobsDict.removeValue(forKey: id)
    }
    
    func set(_ id: JobIdentifier, to data: JobData) async throws {
        self.driver.jobsDict[id] = data
    }
    
    func get(_ id: JobIdentifier) async throws -> JobData {
        print("get \(id)")
        let defaultJob = JobData(payload: [], maxRetryCount: 0, jobName: "", delayUntil: nil, queuedAt: .now)
        
        return self.driver.jobsDict[id, default: defaultJob]
    }
    
}
