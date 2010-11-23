# Circumflex Web Framework   {#web}

Circumflex Web Framework is a DSL for quick and robust web application development.

Here's the sample web application:

    lang:scala
    class Main extends RequestRouter {
      get("/") = "Hello world!"
      get("/posts/:id") = "Post #" + uri("id")
      post("/form") = {
        // do some work
        // render FreeMarker template:
        ftl("/done.ftl")
      }
    }

# Installation & Configuration   {#install}

Circumflex web applications run in standard Servlet 2.5 containers. There's a couple of things
you should do in order to start using Circumflex Web Framework.

First, make sure that `circumflex-core-<version>.jar` and `circumflex-web-<version>.jar` are in
the classpath (add `<dependency>` with `circumflex-core` and `circumflex-web` as described in
[quick start guide](/index.html#start)).

Second, configure `CircumflexFilter` in `/WEB-INF/web.xml`:

    lang:xml
    <web-app version="2.5">
      <filter>
        <filter-name>Circumflex Filter</filter-name>
        <filter-class>ru.circumflex.web.CircumflexFilter</filter-class>
      </filter>
      <filter-mapping>
        <filter-name>Circumflex Filter</filter-name>
        <url-pattern>*</url-pattern>
        <dispatcher>REQUEST</dispatcher>
        <dispatcher>FORWARD</dispatcher>
        <dispatcher>INCLUDE</dispatcher>
        <dispatcher>ERROR</dispatcher>
      </filter-mapping>
    </web-app>

Third, configure the [main request router](#main) of your application by setting `cx.router`
configuration parameter:

  * via `src/main/resource/cx.properties` file:

        cx.router=com.myapp.web.MainRouter

  * or via `pom.xml` [using Circumflex Maven Plugin](/plugins.html#cfg).

Please refer to [Circumflex Configuration API](/core.html#cfg) for more information on how
to configure your application.

## Imports   {#import}

All code examples assume that you have following `import` statement in code where necessary:

    lang:scala
    import ru.circumflex._, core._, web._

# Sample Applications   {#samples}

There's a couple of projects hosted on [GitHub](http://github.com) which can help you understand
[Circumflex Web Framework](#web) better:

  * [vast/ciridiri][] -- dead simple wiki engine;
  * [inca/cx-site][] -- source code of this site;
  * [inca/sandbox-blog][] -- sample Circumflex application which demonstrates the basics of
  [Circumflex Web Framework](#web) and [ORM](/orm.html).

# Basic Concepts {#basics}

## Request Routers {#routers}

Each Circumflex web application is composed of one or more *request routers*.
Request router is a subclass of `RequestRouter` which sequentionally defines [routes](#routes)
directly within its body:

    lang:scala
    class Main extends RequestRouter {
      get("/") = "Hello world!"
      get("/posts/:id") = "Post #" + uri.get("id")
      post("/form") = {
        // Do some work
        // . . .
        // Render FreeMarker template:
        ftl("/done.ftl")
      }
    }

Request routers are essentially the controllers of the application. Since [Circumflex Web Framework](#web)
employs the Front Controller pattern, each web application should have a single
<em id="main">main router</em> -- a special `RequestRouter` which gets executed on every request.
It dispatches all requests of web application.

Request routers can also be easily nested:

    lang:scala
    class MainRouter extends RequestRouter {
      // with matching
      any("/users/*") => new UsersRouter
      any("/posts/*") => new PostsRouter
      any("/mail/*") => new MailRouter
      any("/downloads/*") => new DownloadsRouter
      // unconditionally
      new MiscRouter
    }

It is generally a good practice to have different routers for different tasks -- it makes the code
modular, more organized and easier to maintain.

## Routes   {#routes}

[Circumflex Web Framework](#web) is designed around the *route concept*. A route is an HTTP method
with matching mechanism and attached block.

Routes are defined using one of the following members of `RequestRouter`:

  * `get` (matches HTTP `GET` requests);
  * `post` (matches HTTP `POST` requests);
  * `put` (matches HTTP `PUT` requests);
  * `patch` (matches HTTP `PATCH` requests);
  * `delete` (matches HTTP `DELETE` requests);
  * `options` (matches HTTP `OPTIONS` requests);
  * `head` (matches HTTP `HEAD` requests);
  * `getOrHead` (matches either HTTP `GET` or HTTP `HEAD`);
  * `getOrPost` (matches either HTTP `GET` or HTTP `POST`);
  * `any` (matches any HTTP request).

Each route should define a [matcher](#matchers), which describes the conditions a request must
satisfy to be matched by the route.

Each route also has an associated block which gets executed if matching succeeds. A block must
evaluate to `RouteResponse` which will be sent to client (`String` and `scala.xml.Node` are
converted to `RouteResponse` implicitly):

    lang:scala
    class MyRouter extends RequestRouter {
      get("/hello/:name.txt") = "Hello, " + param("name") + "!"
      get("/hello/:name.xml") = {
        val name = param("name")
        <hello to={name}/>
      }
    }

Upon successful matching the block attached to corresponding route gets executed. Internally
we use `ResponseSentException`, a special control throwable, to indicate that request processing
has been finished. This exception is caught by `CircumflexFilter` which performs response flushing
and finalizes request processing.

Various helpers throw `ResponseSentException` instead of yielding `RouteResponse`:

    lang:scala
    get("/") = redirect("/index.html")

## Matchers  {#matchers}

Request matching can be performed against request URI and zero or more request headers.
The syntax is self-descriptive:

    lang:scala
    get("/")        // matches GET /
    get("/posts")   // matches GET /posts
    post("/posts")  // matches POST /posts

You can combine several matchers in one route using the `&` method:

    lang:scala
    get("/mail" & Accept("text/html") & Host("localhost"))
    // matches following request:
    // GET /mail
    // Host: localhost
    // Accept: text/html

## Parameters  {#params}

Routes can include patterns with named parameters which can be accessed in the attached block.
The following route matches `GET /posts/43` or `GET /posts/foo`; the construct `uri("id")`
is used to capture the parameter from request URI:

    lang:scala
    get("/posts/:id") = "Post #" + uri("id")

Route patterns may also include wildcard parameters (`*` for zero or more characters,
`+` for one or more characters), they can be accessed via index (starting with `1` like
in regex groups):

    lang:scala
    get("/files/+") = "Downloading file " + uri(1)

You may also refer to the whole match with `0` index:

    lang:scala
    get("/files/:name.:ext") = {
      println("The URI is: " + uri(0))
      "Filename is " + uri("name") + ", extension is " + uri("ext")
    }

Named parameters are indexed too:

    lang:scala
    get("*/:two/+/:four") = {
      // uri(2) == uri("two")
      // uri(4) == uri("four")
      (1 to 4).map(i => i + " -> " + uri(i)).mkString("\n")
    }

Parameters can also be extracted using the `param` helper. Unlike `uri`, which represents match
results from URI only, the `param` helper can extract named parameters from headers:

    lang:scala
    get("/" & Accept("text/:format")) = "The format is " + param("format")

You can also extract request parameters using `param`:

    lang:scala
    get("/") = "Limit is " + param("limit") + ", offset is " + param.getOrElse("offset", "0")
    // >> GET /?limit=50&offset=10
    // << Limit is 50, offset is 10
    // >> GET /?limit=5
    // << Limit is 5, offset is 0

## Serving Static files   {#static}

By default static files are served from `<webapp_root>/public` directory. You may override this
by setting `cx.public` configuration parameter.

## Redirecting & Forwarding   {#redirect-rewrite}

You can send `302 Found` HTTP redirect:

    lang:scala
    get("/") = sendRedirect("/index.html")

You can also perform request forwarding (a.k.a. URI rewriting) -- the request will be dispatched
again, but with different URI):

    lang:scala
    get("/") = forward("/index.html")

Note that you should add `<dispatcher>FORWARD</dispatcher>` to `CircumflexFilter` mapping in
your `web.xml` to make forwarding work. You should also avoid infinite forwarding loops manually.

## Sending Errors   {#errors}

You can send errors with specific status code and optional message:

    lang:scala
    get("/") = sendError(500, "We don't work yet.")

## Sending Files   {#send-file}

You can use the `sendFile` helper to send arbitrary file to client:

    lang:scala
    get("/") = sendFile(new File("/path/to/file.txt"))

You can also specify optional `filename` so that `Content-Disposition: attachment` could be
added to response:

    lang:scala
    get("/") = sendFile(new File("/path/to/file.txt"), "greetings.txt")

The content type of the file is guessed based on it's extension. You may override it:

    lang:scala
    get("/") = {
      response.contentType("text/plain")
      sendFile(new File("/path/to/file.text"), "greetings.txt")
    }

You can also use the more efficient `xSendFile` helper to delegate the file transfering to your
web server. This feature is configured via `cx.XSendFile` configuration parameter.
Consult your web server documentation to obtain more information on this feature.

## Handling AJAX Requests   {#xhr}

You can determine if current request is `XmlHttpRequest`:

    lang:scala
    get("/") = if (request.body.xhr_?) "AJAX" else "plain old request"

## Accessing Headers   {#headers}

You get the contents of request headers using the `header` helper:

    get("/") = "Serving to host: " + headers("Host")

## Accessing Session   {#session}

Dealing with session attributes is fairly easy:

    get("/") = {
      // get attribute
      session("attr1")
      // set attribute
      session("attr2") = "My value"
    }

## Flashes   {#flashes}

Flashes provide a way to pass temporary objects between requests:

    lang:scala
    get("/") = flash.get("note") match {
      case Some(value) => "Having a note: " + value
      case None => "No notes for now..."
    }

    post("/") = {
      flash("note") = "Hello from POST, folks!"
      redirect("/")
    }

Anything you place in `flash` helper will be exposed until the first lookup and then cleared out.
This is a great way of dealing with notices and alerts which only need to be shown once.

# Advanced concepts   {#advanced}

This topic reveals some nitty-gritty details about [Circumflex Web Framework](#web).

## Matching   {#adv-matching}

The central abstractions of the route matching mechanism are:

  * `Match` -- holds [parameters](#params) extracted during successful match (already familiar
  helper, `uri`, is `Match` actually);
  * `Matcher` -- performs actual matching and yields a sequence of `Match` objects
  on success.

`Match` objects are designed to be used inside attached blocks of routes, where you can
naturally assume that match succeeded:

    lang:scala
    get("/:name") = uri("name")

`Match` also has `name` which reflects the context where match has occured. URI-based matcher
returns `Match` with name `uri` while headers-based matchers create `Match` objects with the name
of corresponding HTTP header.

You can lookup certain `Match` object in `CircumflexContext` by it's name:

    lang:scala
    get("/foo" & Accept("text/:format")) = ctx("Accept") match {
      case m: Match => "Requested format is " + m("format")
      case _ => ""
    }

In general you don't have to lookup `Match` objects, the `param` helper can retrieve named
parameters from all matches that appear in `CircumflexContext`. So the previous example could be
rewritten in much more convenient manner:

    lang:scala
    get("/foo" & Accept("text/:format")) = "Requested format is " + param("format")

However, there are situations where looking up a `Matcher` can come in handy. For example, you
cannot access splats (wildcard matches) or indexed parameters with `param`:

    lang:scala
    get("/foo" & Accept("text/+")) = ctx("Accept") match {
      case m: Match => "Requested format is " + m(1)
      case _ => ""
    }

Standard `RegexMatcher` can also accept an arbitrary regular expression, the groups will be
accessible from `Match` by their index:

    get("/posts/(\\d+)".r) = {
      val id = uri(1).toLong
      // lookup the post by id and render response
      "..."
    }

## Router Prefix   {#prefix}

You may optionally specify the `prefix` for request router. All URI-based matchers inside the
router will be prepended by this prefix:

    lang:scala
    class PostsRouter extends RequestRouter("/posts") {
      get("/") = "Showing posts"                  // matches GET /posts/
      get("/show/:id") = "Post " + param("id")    // matches GET /posts/show/149
    }

Alternatively, you can let the enclosing router specify a prefix for subrouter:

    lang:scala
    class SubRouter(prefix: String) extends RequestRouter(prefix)

    class MainRouter extends RequestRouter {
      new SubRouter("/prefix-a")
      new SubRouter("/prefix-b")
    }

Note that [main request routers](#main) should have the default zero-arguments constructor,
so the prefix *must* be hardcoded. Generally, main routers have `""` prefix (unless different
filter mappings are specified in `web.xml`).

  [vast/ciridiri]: http://github.com/vast/ciridiri "ciridiri -- dead simple wiki engine"
  [inca/cx-site]: http://github.com/inca/cx-site "Source code of site http://circumflex.ru"
  [inca/sandbox-blog]: http://github.com/inca/sandbox-blog "Sample Circumflex application"
  [Circumflex Web Framework]: #web
