IMPORTANT! We don't see any way how to make web development as great as Ruby on Rails or Django with a very static nature of current Swift. We hope that things will change at some point and we will return to active development.

# Swifton

A Ruby on Rails inspired Web Framework for Swift that runs on Linux and OS X.

![Build Status](https://travis-ci.org/necolt/Swifton.svg?branch=master)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Mac OS X](https://img.shields.io/badge/os-Mac%20OS%20X-green.svg?style=flat)
![Swift 2 compatible](https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat)
[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)
[![codebeat badge](https://codebeat.co/badges/c5246f1f-d1cd-4424-b9ec-9340a175a844)](https://codebeat.co/projects/github-com-necolt-swifton)

## Getting Started

* Install Development snapshot [version](https://github.com/necolt/Swifton/blob/master/.swift-version) from [Swift.org](https://swift.org/download/) or via [swiftenv](https://github.com/kylef/swiftenv). If you are on OSX I highly recommend [swiftenv](https://github.com/kylef/swiftenv) - latest Swift will be able to coexist with system wide Swift that comes with Xcode.
* ```swift --version``` should show something like: ```Swift version 3.0-dev ...```
* Checkout [TodoApp](https://github.com/necolt/Swifton-TodoApp) example project.
* Run ```swift build``` inside app (most of dependencies throw deprecation warnings).
* Run ```./.build/debug/Swifton-TodoApp```.
* Open ```http://0.0.0.0:8000/todos``` in your browser.

## Contributing

Contributions are more than welcome! The easiest way to start contributing to Swifton: 

* Setup [TodoApp](https://github.com/necolt/Swifton-TodoApp) 
* Pick one issue from the [issues list](https://github.com/necolt/swifton/issues) or propose enhancement. 
* You can find Swifton source code in ```Swifton-TodoApp/Packages/Swifton-<version>``` directory. Packages inside ```Packages``` directory comes with Git repository so feel free to do you changes there.
* Compile and test [TodoApp](https://github.com/necolt/Swifton-TodoApp), this will help to check your changes and avoid regressions.
* Write tests and run it ```swift build && swift test``` (run ```rm -r Packages/*/Tests``` inside Swifton folder if tests crashes)
* Commit and push your changes, open pull request.
* Enjoy ;) 

## Routing

Swifton comes with ready to use Router, also you can use any router as long as it accepts Request and returns Response. Routes are defined in ```main.swift``` file. Configured Router is passed to [S4](https://github.com/open-swift) interface supporting server. Router allows to define ```resources``` and regular routes.

```swift
...
let router = Router.create { route in
  route.resources("todos", controller: TodosController())
}
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

A controller inherits from ApplicationController class, which inherits from Controller class. Action is a closure that accepts Request object and returns Response object. 

```swift
class TodosController: ApplicationController { 
    // shared todo variable used to pass value between setTodo filter and actions
    var todo: Todo?    
    override func controller() {
    super.controller()
    // sets before filter setTodo only for specified actions.
    beforeAction("setTodo", only: ["show", "edit", "update", "destroy"])

    // render all Todo instances with Index template (in Views/Todos/Index.html.stencil)
    action("index") { request in
        let todos = ["todos": Todo.allAttributes()]
        return render("Todos/Index", todos)
    }

    // render Todo instance that was set in before filter
    action("show") { request in
        return render("Todos/Show", self.todo)
    }

    // render static New template
    action("new") { request in
        return render("Todos/New")
    }

    // render Todo instance's edit form
    action("edit") { request in
        return render("Todos/Edit", self.todo)
    } 

    // create new Todo instance and redirect to list of Todos 
    action("create") { request in
        Todo.create(request.params)
        return redirectTo("/todos")
    }
    
    // update Todo instance and redirect to updated Todo instance
    action("update") { request in
        self.todo!.update(request.params)
        return redirectTo("/todos/\(self.todo!.id)")
    }

    // destroy Todo instance
    action("destroy") { request in
        Todo.destroy(self.todo)
        return redirectTo("/todos")
    }

    // set todo shared variable to actions can use it
    filter("setTodo") { request in
        // Redirect to "/todos" list if Todo instance is not found 
        guard let t = Todo.find(request.params["id"]) else { return self.redirectTo("/todos") } 
        self.todo = t as? Todo
        // Run next filter or action
        return self.next
    }

}}

```
### Controller Responders

```respondTo``` allows to define multiple responders based client ```Accept``` header:

```swift 
...
action("show") { request in
    return respondTo(request, [
        "html": { render("Todos/Show", self.todo) },
        "json": { renderJSON(self.todo) }
    ])
}
...

```

### Controller Filters

Swifton Controllers support ```beforeAction``` and ```afterAction``` filters, which run filters before or after action correspodingly. Filter is a closure that returns ```Response?```. Controller proceeds execution only if filter returns ```self.next``` (which is actually ```nil```), otherwise it returns ```Response``` object and doesn't proceed execution of other filters and action.  

```swift
filter("setTodo") { request in
    // Redirect to "/todos" list if Todo instance is not found
    guard let t = Todo.find(request.params["id"]) else { return self.redirectTo("/todos") }
    self.todo = t as? Todo
    // Run next filter or action
    return self.next
}
```

## Models

Swifton is ORM agnostic web framework. You can use any ORM of your choice. Swifton comes with simple in-memory MemoryModel class that you can inherit and use for your apps. Simple as this: 

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
user["surname"] // "Bond"
User.destroy(user)
User.all.count // 0

```

Few options if you need persistence:

* [PostgreSQL](https://github.com/Zewo/PostgreSQL) adapter.
* [MySQL](https://github.com/Zewo/MySQL) adapter.
* [Fluent](https://github.com/qutheory/fluent) simple SQLite ORM. 

## Views

Swifton supports Mustache like templates via [Stencil](https://github.com/kylef/Stencil) template language. View is rendered with controller's method ```render(template_path, object)```. Object needs either to conform to ```HTMLRenderable``` protocol, either be ```[String: Any]``` type where ```Any``` allows to pass complex structures.

```html
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

Views are loaded from ```Views``` directory by default, you can also change this default setting by changing value of ```SwiftonConfig.viewsDirectory``` (preferable in ```main.swift``` file). Currently views are not cached, so you don't need to restart server or recompile after views are changed. 

Static assets (JavaScript, CSS, images etc.) are loaded from ```Public``` directory by default, you can also change this default setting by changing value of ```SwiftonConfig.publicDirectory``` (preferable in ```main.swift``` file).

## JSON support

```renderJSON(object)``` generates and returns JSON of an object. Object must conform to ```JSONRenderable``` protocol.

```swift
action("show") { request in
    return respondTo(request, [
        "html": { render("Todos/Show", self.todo) },
        "json": { renderJSON(self.todo) }
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

Swifton comes with [VeniceX](https://github.com/VeniceX/Venice) based HTTP server. Swifton supports [S4](https://github.com/open-swift/S4) HTTP standards for Swift so you can easily use any [S4](https://github.com/open-swift/S4) supporting server. 

### Building for production

Build ```release``` configuration for better performance:

```shell
$ swift build --configuration release
```
## Deployment

### Heroku

Example [TodoApp](https://github.com/necolt/Swifton-TodoApp) can be deployed to Heroku using the [heroku-buildpack-swift](https://github.com/kylef/heroku-buildpack-swift).

Click the button below to automatically set up this example to run on your own Heroku account.

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/necolt/Swifton-TodoApp)

### Docker 

Swifton can be deployed with Docker. Some examples how to deploy it with Docker:
* [TodoApp](https://github.com/necolt/Swifton-TodoApp) on EC2 Container Services (ECS) [example](http://ngs.io/2016/03/04/swift-webapp-on-ecs/)
* Docker Container for the Apple's Swift programming language - [docker-swift](https://github.com/swiftdocker/docker-swift).

