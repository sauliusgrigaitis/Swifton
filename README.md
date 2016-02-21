![Swifton](https://pbs.twimg.com/media/BspM9nCCcAAKcij.jpg)

# Swifton - Swift on Rails

A Ruby on Rails inspired Web Framework for Swift that runs on Linux and OS X.

## Getting Started

* Install latest Development snapshot from [Swift.org](https://swift.org/download/) or via [swiftenv](https://github.com/kylef/swiftenv)(recommended).
* ```swift --version``` should show something like:

```
Swift version 3.0-dev (LLVM a7663bb722, Clang 4ca3c7fa28, Swift 1c2f40e246)
Target: x86_64-unknown-linux-gnu
```

* Checkout [TodoApp](https://github.com/necolt/Swifton-TodoApp) example project.
* Run ```swift build``` inside app (most of dependencies throw deprecation warnings).
* Run ```./.build/debug/Swifton-TodoApp```.
* Open ```http://0.0.0.0:8000/todos``` in your browser.

## Routing

Swifton comes with ready to use Router, also you can use any router as long as it accepts Request and returns Response. Routes are defined in ```main.swift``` file. Configured Router is passed to [Nest](https://github.com/nestproject/Nest) interface supporting server. Swifton Router supports [RFC6570](https://tools.ietf.org/html/rfc6570) URI Templates via [URITemplate](https://github.com/kylef/URITemplate.swift) library. Router allows to define ```resources``` and regular routes.

```swift
...
let router = Router()
router.resources("todos", TodosController())
...
```

Which is equivalent to:

```swift
let router = Router()
router.get("/todos/new", TodosController()["new"])
router.get("/todos/{id}", TodosController()["show"])
router.get("/todos/{id}/edit", TodosController()["edit"])
router.get("/todos", TodosController()["index"])
router.post("/todos", TodosController()["create"])
router.delete("/todos/{id}", TodosController()["destroy"])
router.patch("/todos/{id}", TodosController()["update"])
```

Configured routes then are passed to application server.

```swift
...
serve { request in
    router.respond(request) 
}
...
```

## Controllers 

A controller inherits from ApplicationController class, which inherits from Controller class. Action is a closure that accepts Request object and returns Response object. ```beforeAction``` and ```afterAction``` allows to register filters before and after action is executed. 

```swift
class TodosController: ApplicationController { 
    // shared todo variable used to pass value between setTodo filter and actions
    var todo: Todo?    
    override init() { super.init()

    // sets before filter setTodo only for specified actions 
    beforeAction("setTodo", ["only": ["show", "edit", "update", "destroy"]])

    // render all Todo instances with Index template (in Views/Todos/Index.html.stencil)
    action("index") { request in
        let todos = ["todos": Todo.allAttributes()]
        return self.render("Todos/Index", todos)
    }

    // render Todo instance that was set in before filter
    action("show") { request in
        return self.render("Todos/Show", self.todo)
    }

    // render static New template
    action("new") { request in
        return self.render("Todos/New")
    }

    // render Todo instance's edit form
    action("edit") { request in
        return self.render("Todos/Edit", self.todo)
    } 

    // create new Todo instance and redirect to list of Todos 
    action("create") { request in
        Todo.create(request.params)
        return self.redirectTo("/todos")
    }
    
    // update Todo instance and redirect to updated Todo instance
    action("update") { request in
        self.todo!.update(request.params)
        return self.redirectTo("/todos/\(self.todo!.id)")
    }

    // destroy Todo instance
    action("destroy") { request in
        Todo.destroy(self.todo)
        return self.redirectTo("/todos")
    }

    // set todo shared variable to actions can use it
    filter("setTodo") { request in
        if let t = Todo.find(request.params["id"]) { 
            self.todo = t as? Todo
        }
    }

}}

```

```respondTo``` allows to define multiple responders based client ```Accept``` header:

```swift 
...
action("show") { request in
    return self.respondTo(request, [
        "html": { self.render("Todos/Show", self.todo) },
        "json": { self.renderJSON(self.todo) }
    ])
}
...

```

## Models

Swifton is ORM angostic web framework. You can use any ORM of your choice. Swifton comes with simple in-memory MemoryModel class that you can inherit and use for your apps. Simple as this: 

```swift
class User: MemoryModel {
}

...

User.all.count // 0
var user = User.create(["name": "Saulius", "surname": "Grigaitis"])
User.all.count // 1
user["name"] // "Saulius"
user["surname"] // "Grigaitis"
user.update(["name": "James", "surname": "Bond"])
user["surname"]) // "Bond"
User.destroy(user)
User.all.count // 0

```

Few options if you need persistence:

* [PostgreSQL](https://github.com/Zewo/PostgreSQL) adapter.
* [MySQL](https://github.com/Zewo/MySQL) adapter.
* [Fluent](https://github.com/tannernelson/fluent) simple SQLite ORM. 

## Views

Swifton supports Mustache like templates via [Stencil](https://github.com/kylef/Stencil) template language. View is rendered with controller's method ```render(template_path, object)```. Object needs either to conform to ```HTMLRenderable``` protocol, either be ```[String: Any]``` type where ```Any``` allows to pass complex structures.

Views are loaded from ```Views``` directory by default, you can also change this default setting by changing value of ```SwiftonConfig.viewsDirectory``` (preferable in ```main.swift``` file). Currently views are not cached, so you don't need to restart server or recompile after views are changed. 

Static assets (JavaScript, CSS, images etc.) are loaded from ```Public``` directory by default, you can also change this default setting by changing value of ```SwiftonConfig.publicDirectory``` (preferable in ```main.swift``` file).

```
<tbody>
  {% for todo in todos %}
    <tr>
      <td>{{ todo.title }}</td>
      <td>{{ todo.completed }}</td>
      <td><a href="/todos/{{ todo.id }}">Show</a></td>
      <td><a href="/todos/{{ todo.id }}/edit">Edit</a></td>
      <td><a data-confirm="Are you sure?" rel="nofollow" data-method="delete" href="/todos/{{ todo.id }}">Destroy</a></td>
    </tr>
  {% endfor %}
</tbody>

```

## JSON support

```renderJSON(object)``` generates and returns JSON of an object. Object must conform to ```JSONRenderable``` protocol.

```swift
action("show") { request in
    return self.respondTo(request, [
        "html": { self.render("Todos/Show", self.todo) },
        "json": { self.renderJSON(self.todo) }
    ])
}
```

## Middleware

```main.swift``` is probably best place to put middleware. Simply wrap ```Router``` instance with your middleware, you can even nest multiple middlewares.  

```swift
...
serve { request in
    router.respond(request) 
}
...
```

## Application Server

Swifton comes with [Currasow](https://github.com/kylef/Curassow) server. [Curassow](https://github.com/kylef/Curassow) is a Swift [Nest](https://github.com/nestproject/Nest) HTTP Server. It uses the pre-fork worker model and it's similar to Python's Gunicorn and Ruby's Unicorn. Swifton applications should run on other [Nest](https://github.com/nestproject/Nest) servers with none or minimal modifications.

Curassow provides a command line interface to configure the address you want to listen on and the amount of workers you wish to use.

### Building for production

Build ```release``` configuration for better performance:

```shell
$ swift build --configuration release
```

### Setting the workers

```shell
$ ./.build/release/Swifton-TodoApp --workers 4 
[arbiter] Listening on 0.0.0.0:8000
[arbiter] Started worker process 18405
[arbiter] Started worker process 18406
[arbiter] Started worker process 18407
```

### Configuring the address

```shell
$ ./.build/release/Swifton-TodoApp --bind 127.0.0.1:9000
[arbiter] Listening on 127.0.0.1:9000
```

### Configuring worker timeouts

By default, Curassow will kill and restart workers after 30 seconds if it
hasn't responded to the master process.

```shell
$ ./.build/release/Swifton-TodoApp --timeout 30
```

## Deployment

### Heroku

Example [TodoApp](https://github.com/necolt/Swifton-TodoApp) can be deployed to Heroku using the [heroku-buildpack-swift](https://github.com/kylef/heroku-buildpack-swift).

Click the button below to automatically set up this example to run on your own Heroku account.

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/necolt/Swifton-TodoApp)

### Docker 

Example [TodoApp](https://github.com/necolt/Swifton-TodoApp) can be deployed on Docker using the [docker-swift](https://github.com/swiftdocker/docker-swift).
