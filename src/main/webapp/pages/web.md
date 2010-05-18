Circumflex Web Framework   {#web}
========================

Circumflex Web Framework is a DSL for quick and robust web application development.

Here's a simple web application:

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

Third, configure the [main request router](#main) of your application. You can do this in one of
the following ways.

  * Specify `cx.router` property in `cx.properties`:

        cx.router=com.myapp.web.MainRouter

  This file should be in the classpath, (typically in `/WEB-INF/classes` of your web application);
  if you use Maven, just place it into `src/main/resources` directory.

  * Specify `cx.router` property in your `pom.xml` and configure `maven-cx-plugin`:

        lang:xml
        <project xmlns="http://maven.apache.org/POM/4.0.0">
          ...
          <properties>
            <cx.version>1.1</cx.version>
            <cx.router>com.myapp.web.MainRouter</cx.router>
          </properties>
          <build>
            <plugins>
              <plugin>
                <groupId>ru.circumflex</groupId>
                <artifactId>maven-cx-plugin</artifactId>
                <version>${cx.version}</version>
                <executions>
                  <execution>
                    <id>configure</id>
                    <phase>compile</phase>
                    <goals>
                      <goal>cfg</goal>
                    </goals>
                  </execution>
                </executions>
              </plugin>
            </plugins>
          </build>
        </project>

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

Each web application should also have a single <em id="main">main router</em> -- a special
`RequestRouter` that gets executed on every request. It serves as an entry point for web
application.

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
that yields `HttpResponse` will do the job. See [responses](#responses) for a list of predefined
responses.

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
The following route matches `GET /posts/43` or `GET /posts/foo`; `uri("id")` is used to
capture the parameter from request URI:

    lang:scala
    get("/posts/:id") = "Post #" + uri("id")

Route patterns may also include wildcard parameters (`*` for zero or more characters,
`+` for one or more characters):

    lang:scala
    get("/files/*") = "Downloading file " + uri(1)