Circumflex Web Framework   {#web}
========================

Circumflex Web Framework is a DSL for quick and robust web application development.

Here's the sample web application:

    lang:scala
    class Main extends RequestRouter {
      get("/") = "Hello world!"
      get("/posts/:id") = "Post #" + uri("id")
      post("/form") = {
        // Do some work
        // . . .
        // Render FreeMarker template:
        ftl("/done.ftl")
      }
    }

## Installation & Configuration

Circumflex web application runs in standard Servlet 2.5 Containers. There's a couple of things
you should do in order to start using Circumflex Web Framework.

First, make sure that `circumflex-core-<version>.jar` is in the classpath (add `<dependency>` to
`circumflex-core` as described in [quick start guide](/index.html#start) or just copy the
JAR-file to `/WEB-INF/lib` of your web application).

Second, configure `CircumflexFilter` in `/WEB-INF/web.xml`:

    lang:xml
    <web-app version="2.5">
      <filter>
        <filter-name>Circumflex Core Filter</filter-name>
        <filter-class>ru.circumflex.core.CircumflexFilter</filter-class>
      </filter>
      <filter-mapping>
        <filter-name>Circumflex Core Filter</filter-name>
        <url-pattern>*</url-pattern>
        <dispatcher>REQUEST</dispatcher>
        <dispatcher>FORWARD</dispatcher>
        <dispatcher>INCLUDE</dispatcher>
        <dispatcher>ERROR</dispatcher>
      </filter-mapping>
    </web-app>

Third, configure the [main request router](#main) of your application by setting `cx.router`
[configuration parameter](#cfg). You can do this in one of the following ways.

  * Specify `cx.router` property in `cx.properties`:

        cx.router=com.myapp.web.MainRouter

  This file should be in the classpath, (typically in `/WEB-INF/classes` of your web application);
  if you use Maven, just place it into `src/main/resources` directory.

  * Specify `cx.router` property in your `pom.xml` and configure `maven-cx-plugin`:

        lang:xml
        <project xmlns="http://maven.apache.org/POM/4.0.0">
          ...
          <properties>
            <cx.router>com.myapp.web.MainRouter</cx.router>
          </properties>
          ...
        </project>

    Note that you should also add an execution for `cfg` goal of `maven-cx-plugin` to your
    `pom.xml`, see the [Circumflex Maven Plugin documentation](/plugin.html#cfg) for more details.

## Sample Applications

There's a couple of projects hosted on [GitHub](http://github.com) that can help you understand
Circumflex Web Framework better:

  * [vast/ciridiri][] -- dead simple wiki engine;
  * [inca/cx-site][] -- source code of this site;
  * [inca/sandbox-blog][] -- sample Circumflex application which demonstrates the basics of
  Circumflex Web Framework and [ORM](/orm.html).

## Request Routers {#routers}

Each Circumflex web application is composed of one or more *request routers*.
Request router is a subclass of `RequestRouter` which sequentionally defines [routes](#routes)
directly within it's body:

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

Request routers are essentially the controllers of the application. Since Circumflex Web Framework
employs the Front Controller pattern, each web application should have a single
<em id="main">main router</em> -- a special `RequestRouter` that gets executed on every request.
It dispatches all requests of web application.

Request routers can also be easily nested:

    lang:scala
    class MainRouter extends RequestRouter {
      new UsersRouter
      new PostsRouter
      new MailRouter
      new DownloadsRouter
    }

It is generally a good practice to have different routers for different tasks -- it makes the code
modular, more organized and easier to maintain.

## Routes   {#routes}

Circumflex Web Framework is designed around the *route concept*. A route is an HTTP method with
matching mechanism and attached block.

Routes are defined using one of the following members of `RequestRouter`:

  * `get` (matches HTTP `GET`);
  * `post` (matches HTTP `POST`);
  * `put` (matches HTTP `PUT`);
  * `delete` (matches HTTP `DELETE`);
  * `options` (matches HTTP `OPTIONS`);
  * `head` (matches HTTP `HEAD`);
  * `getOrHead` (matches either HTTP `GET` or HTTP `HEAD`);
  * `getOrPost` (matches either HTTP `GET` or HTTP `POST`);
  * `any` (matches any HTTP method).

Each route should define a [matcher](#matchers), which describes the conditions a request must
satisfy to be matched by the route.

Finally, a block is attached to the route. This block gets executed if matching succeeds. Any block
that yields `HttpResponse` will do the job. Basically, you return `TextResponse` (`java.lang.String`
and `scala.xml.Node` are converted to `TextResponse` implicitly) or use one of [helpers](#helpers)
to render some view or send redirect, error or file.

## Matchers  {#matchers}

The matching can be performed against request URI and zero or more request headers.
The syntax is rather self-descriptive:

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

Routes can include patterns with named parameters that can be accessed in the attached block.
The following route matches `GET /posts/43` or `GET /posts/foo`; the construct `uri("id")`
is used to capture the parameter from request URI:

    lang:scala
    get("/posts/:id") = "Post #" + uri("id")

Route patterns may also include wildcard parameters (`*` for zero or more characters,
`+` for one or more characters), they are accessible via index:

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

Parameters can also be extracted using the `param` helper. Unlike `uri`, which represents a match
from URI only, the `param` helper can extract named parameters from headers:

    lang:scala
    get("/" & Accept("text/:format")) = "The format is " + param("format")

You can also extract request parameters using `param`:

    lang:scala
    get("/") = "Limit is " + param("limit") + ", offset is " + param("offset")

In the above example, request `GET /?limit=50&offset=10` will result in following response: 

    lang:no-highlight
    Limit is 50, offset is 10

## Static files   {#static}

By default static files are served from `<webapp_root>/public` directory. You may override this
by setting `cx.public` [configuration parameter](#cfg).

## Helpers   {#helpers}

### Redirecting and URI Rewriting   {#redirect-rewrite}

You can send `302 Found` HTTP redirect:

    lang:scala
    get("/") = redirect("/index.html")

You can also perform URI rewriting (the request will be dispatched again, but with different URI):

    lang:scala
    get("/") = rewrite("/index.html")

Note that you should add `<dispatcher>FORWARD</dispatcher>` to `CircumflexFilter` mapping in
your `web.xml` tomake rewrites work. You should also avoid infinite rewrite loops.

### Sending errors   {#errors}

You can send errors with specific status code and optional message:

    lang:scala
    get("/") = error(500, "We don't work yet.")

### Sending files   {#send-file}

You can use the `sendFile` helper to send arbitrary file to client:

    lang:scala
    get("/") = sendFile(new File("/path/to/file.txt"))

You may also specify optional `filename` so that `Content-Disposition: attachment` could be
added to response:

    lang:scala
    get("/") = sendFile(new File("/path/to/file.txt"), "greetings.txt")

The content type of the file is guessed based on it's extension. You may override it:

    lang:scala
    get("/") = {
      contentType("text/plain")
      sendFile(new File("/path/to/file.text"), "greetings.txt")
    }

You can also use the more efficient `xSendFile` helper to delegate the file transfering to your
web server. This feature is configured via `cx.XSendFileHeader` [configuration parameter](#cfg).
Consult your web server documentation to obtain more information on this feature.

### Handling AJAX Requests

You can determine if current request is `XmlHttpRequest`:

    lang:scala
    get("/") = if (xhr_?) "AJAX" else "plain old request"

### Accessing Headers   {#headers}

You get the contents of request headers using the `header` helper:

    get("/") = "Serving to host: " + header("Host")

### Accessing Session   {#session}

Dealing with session attributes is fairly easy:

    get("/") = {
      // get attribute
      session("attr1")
      // set attribute
      session("attr2") = "My value"
    }

### Flashes   {#flashes}

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
    
## Advanced concepts   {#advanced}

This topic reveals some nitty-gritty details about Circumflex Web Framework.

### The Circumflex Context   {#adv-context}

`CircumflexContext` maintains the current state of the request. It is instantiated thread-locally
on every request and can be accessed via `ctx` method inside routers:

    lang:scala
    get("/") = ctx.toString

It holds low-level `HttpServletRequest` and `HttpServletResponse` objects just in case you
might need them:

    lang:scala
    get("/") = {
      val req = ctx.request   // do something with raw request
      val res = ctx.response  // do something with raw response
      ""
    }

But the most important role of `CircumflexContext` is to various parameters so that data from
controllers can be accessed in views:

    lang:scala
    get("/") = {
      // add some parameters to context to show them in template:
      ctx("phrase") = "Roses are red, violets are blue."
      // this neat syntax is also available:
      "someList" := List("one","two","three")
      // finally, render the template:
      ftl("/index.ftl")
    }

In the example above `CircumflexContext` acts as a data-carrier unit to deliver objects to the
[Freemarker view](/ftl.html). Here's the sample view:

    lang:no-highlight
    [#ftl]
    <p id="phrase">${phrase}</p>
    <ul>
    [#list someList as l]
      <li>${l}</li>
    [/#list]
    </li>

The rendered response would look like this:

    lang:xml
    <p id="phrase">Roses are red, violets are blue.</p>
    <ul>
      <li>one</li>
      <li>two</li>
      <li>three</li>
    </ul>

### Matching   {#adv-matching}

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

### Router Prefix   {#prefix}

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

### Configuration Parameters   {#cfg}

All Circumflex components share the same approach to configuration. Configuration parameters are
read from `cx.properties` file, it should be in the classpath, (typically in `/WEB-INF/classes`
of your web application); if you use Maven, just place it into `src/main/resources` directory.

However, there is a more convenient and robust way to set Circumflex configuration parameters using
[Circumflex Maven Plugin](/plguin.html#cfg).

The following parameters are recognized by Circumflex Web Framework:

  * `cx.router` -- fully-qualified class name of the [main request router](#main) for application;
  * `cx.public` -- directory (relative to web application root) for serving static
  files;
  * `cx.XSendFileHeader` -- fully-qualified class name of the `XSendFileHeader` implementation
  that will be used by `xSendFile` helper.


  [vast/ciridiri]: http://github.com/vast/ciridiri "ciridiri -- dead simple wiki engine"
  [inca/cx-site]: http://github.com/inca/cx-site "Source code of site http://circumflex.ru"
  [inca/sandbox-blog]: http://github.com/inca/sandbox-blog "Sample Circumflex application"