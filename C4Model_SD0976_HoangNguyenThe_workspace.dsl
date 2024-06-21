# Open with https://structurizr.com/dsl

workspace "Books Store System" "[NT][C4 model] SD0976-HoangNguyenThe" {
    model {
        ## Objects Definition
        # People/Actor
        # <variable> = person <name> <description> <tag>
        publicUser = person "Public User" "An anonymous user of the bookstore" "User"
        authorizedUser = person "Authorized User" "A registered user of the bookstore, with personal account" "User"
        internalUser = person "Internal User" "Admin user of the bookstore" "User"

        # Our System
        # <variable> = softwareSystem <name> <description> <tag>
        bookstoreSystem = softwareSystem "Bookstore System" "Allows users to view about book, and administrate the book details" "Target System" {
            # Level 2: Containers
            # <variable> = container <name> <description> <technology> <tag>
            frontStoreApplication = container "Front-store Application" "Provide all the bookstore functionalities to both public and authorized users" "JavaScript & ReactJS"
            backOfficeApplication = container "Back-office Application" "Provide all the bookstore administration functionalities to internal users" "JavaScript & ReactJS"
            searchApi = container "Search API" "Allows only authorized users searching books records via HTTPS API" "Go"
            elasticsearchDatabase = container "Elasticsearch Database" "Stores searchable book information" "ElasticSearch" "NoSQL"
            publicWebApi = container "Public Web API" "Allows publish users to search books information using HTTPs API" "Go"
            adminWebApi = container "Admin Web API" "Allow ONLY internal users to manage books and purchases information using HTTPs API" "Go" {
                # Level 3: Components
                # <variable> = component <name> <description> <technology> <tag>
                bookService = component "Book Service" "Allows administrating book details. It reads and writes data to Bookstore Database" "Go"
                authService = component "Authorizer" "Authorize users by using external Identity Provider System" "Go"
                bookEventPublisher = component "Book Events Publisher" "Publishes books-related events to Book Event System" "Go"
            }
            bookstoreDatabase = container "Bookstore Database" "Stores book details" "PostgreSQL" "Database"
            bookEventSystem = container "Book Event System" "Handle the book published event and forward to the Book Event Consumer" "Apache Kafka 3.0"
            bookSearchEventConsumer = container "Book Search Event Consumer" "Consume book update events and write to Elasticsearch Database" "Go"
            publisherRecurrentUpdater = container "Publisher Recurrent Updater" "Listening to external events from Publisher System, and update book information" "Go"
        }
        
        # External Systems
        authSystem = softwareSystem "Identity Provider System" "The external Identiy Provider Platform" "External System"
        publisherSystem = softwareSystem "Publisher System" "The 3rd party system of publishers that gives details about newly published books" "External System"
        deliverySystem = softwareSystem "Shipping Service" "The 3rd party system to handler the book delivery" "External System"




        ## Communications
         # <variable> -> <variable> <description> <protocol>
 
        # Relationship between People and Software Systems
        publicUser -> bookstoreSystem "View books"
        authorizedUser -> bookstoreSystem "Search book details and place order"
        internalUser -> bookstoreSystem "Administrate books and purchases"
        bookstoreSystem -> authSystem "Register new user, authenticate user and authorize request"
        bookstoreSystem -> deliverySystem "Delivery books"

        # Relationship between People and Containers
        publicUser -> frontStoreApplication "Interact with"
        authorizedUser -> frontStoreApplication "Interact with"
        internalUser -> backOfficeApplication "Administrate books and purchases"

        # Relationship between Container and Container
        frontStoreApplication -> authSystem "Authenticate user" "JSON/HTTPS"
        frontStoreApplication -> publicWebApi "Search book and place order" "JSON/HTTPS"
        frontStoreApplication -> searchApi "Search book details" "JSON/HTTPS"
        backOfficeApplication -> adminWebApi "Administrate books and purchases" "JSON/HTTPS"
        searchApi -> elasticsearchDatabase "Retrieve book search data" "ODBC"
        publicWebApi -> elasticsearchDatabase "Retrieve book search data" "ODBC"
        adminWebApi -> bookstoreDatabase "Reads/Write book detail data" "ODBC"
        publisherRecurrentUpdater -> adminWebApi "Makes API calls to update the data changes" "JSON/HTTPS"
        adminWebApi -> bookEventSystem "Publish the Event"
        bookEventSystem -> bookSearchEventConsumer "Forward the event"
        bookSearchEventConsumer -> elasticsearchDatabase "Write book info to the Elasticsearch Database" "NoSQL"

        # Relationship between Containers and External System
        searchApi -> authSystem "Authorize request" "JSON/HTTPS"
        adminWebApi -> authSystem "Authorize request" "JSON/HTTPS"
        publisherSystem -> publisherRecurrentUpdater "Publish events of new book publication" {
            tags "Async Request"
        }

        # Relationship between Component with Container
        bookService -> bookstoreDatabase "Reads/Write book detail data"

        # Relationship between Component with Component
        bookService -> authService "Authenticate/authorize"
        bookService -> bookEventPublisher "Call"

        # Relationship between Components and Other Containers
        authService -> authSystem "Authenticate user and authorize a request" "JSON/HTTPS"
        bookService -> bookstoreDatabase "Read/Write data" "ODBC"
        bookEventPublisher -> bookEventSystem "Publish events about book updating"
    }

	## Deployment: N/A


    views {
        # Level 1
        systemContext bookstoreSystem "SystemContext" {
            include *
            # default: tb,
            # support tb, bt, lr, rl
            autoLayout lr
        }
        # Level 2
        container bookstoreSystem "Containers" {
            include *
            autoLayout lr
        }
        # Level 3
        component adminWebApi "Components" {
            include *
            autoLayout
        }

        # Deployment: N/A

        styles {
            # element <tag> {}
            element "Customer" {
                background #08427B
                color #ffffff
                fontSize 22
                shape Person
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            relationship "Relationship" {
                dashed false
            }
            relationship "Async Request" {
                dashed true
            }
            element "Database" {
                shape Cylinder
            }
            element "NoSQL" {
                shape Cylinder
            }
        }

        theme default
    }

}