# Circumflex Core {#core}

Circumflex Core is a tiny library shared by all Circumflex projects. It consists
of following components.

  * [Configuration API](#cfg)
  * [Context API](#ctx)
  * [Messages API](#msg)

You should familiarize yourself with Circumflex Core concepts to gain maximum efficiency
from your development.

# Configuration API {#cfg}

All Circumflex components share the same approach to configuration. Configuration parameters
offer applications and libraries a way to alter their behavior under different environments
and deployment scenarios, thus eliminating the need of revisiting the code.

You may specify configuration parameters in two different ways.

  * Specify configuration parameters in `cx.properties` file:

        cx.router=com.myapp.web.MainRouter

  This file should be in the classpath; if you use Maven, just place it into `src/main/resources`
  directory.

  * Specify configuration parameters in the `<properties>` section your `pom.xml` and configure
  `maven-cx-plugin`:

        lang:xml
        <project xmlns="http://maven.apache.org/POM/4.0.0">
          <properties>
            <cx.router>com.myapp.web.MainRouter</cx.router>
          </properties>
          ...
          <build>
            <plugins>
              <plugin>
                <groupId>ru.circumflex</groupId>
                <artifactId>maven-cx-plugin</artifactId>
                <version>${cx.version}</version>
                <executions>
                  <execution>
                    <id>configure</id>
                    <phase>process-resources</phase>
                    <goals>
                      <goal>cfg</goal>
                    </goals>
                  </execution>
                </executions>
              </plugin>
            </plugins>
          </build>
        </project>

  See the [Circumflex Maven Plugin documentation](/plugin.html#cfg) for more details.

Of course, nothing stops you from using Circumflex to deal with your own configuration.
It's pretty simple:

    lang:scala
    val cfg = cx.get("myCfgParam") match {
      case s: String => ...
      case cfg: MyConfigurationObject => ...
      case _ => ...
    }

You can also configure your application programmatically:

    lang:scala
    cx("myCfgParam") = new MyConfigurationObject

For further information refer to [Circumflex API documentation](/api/2.0/circumflex-core/circumflex.scala).

# Context API {#ctx}

Context is a thread-local container which allows you to share objects (also known as
context variables) within one logical scope.

Such logical scope could be anything: database transaction, HTTP request, user
session within GUI form, etc. Within this scope you can obtain current context by
calling `Context.get` method (or using `ctx` method of package `ru.circumflex.core`).

Most Circumflex components depend on context and, therefore, can only be run inside
context-aware code. Application is responsible for maintaining context lifecycle.
For example, [Circumflex Web Framework](/web.html) takes care of context initialization
and finalization inside `CircumflexFilter`.

Inside context scope you can store and access context variables using following syntax:

    lang:scala
    // store
    ctx("myParam") = new MyObject
    'myParam := new MyObject
    'myParam.update(new MyObject)
    // access
    ctx.getAs[T]("myParam")              // Option[T]
    'myParam.get[T]                      // Option[T]
    'myParam.getOrElse[T](default: T)    // T

For further information refer to [Circumflex API documentation](/api/2.0/circumflex-core/context.scala).

# Messages API {#msg}

Messages API offers you a convenient way to internationalize your application.

Generally, all strings which should be presented to user are stored in
separate `.properties`-files as suggested by [Java Internationalization][java-i18n].

Circumflex Messages API goes beyound this simple approach and offers
delegating resolving, messages grouping, parameters interpolation and formatting.

  [java-i18n]: http://java.sun.com/javase/technologies/core/basic/intl

The usage is pretty simple: you use the `msg` method of package object `ru.circumflex.core`
to retrieve localized messages by keys:

    lang:scala
    val greeting = msg("hello")
    val tagName = msg.getOrElse("someTag", "unknown")

Then you specify message bundles in `src/main/resources` with base name `Messages`
(the location and the base name can be changed with `cx.messages.root` and `cx.messages.name`
configuration parameters):

    lang:no-highlight
    # src/main/resources/Messages.properties
    hello=Hello!
    # src/main/resources/Messages_pt.properties
    hello=Hola!

The locale is taken from `cx.locale` context variable (see `Context` for more details).
If no such variable found in the context, then the platform's default locale is used.

Circumflex Messages API features very robust ranged resolving. The message is searched
using the range of keys, from the most specific to the most general ones: if the message
is not resolved with given key, then the key is truncated from the left side to
the first dot (`.`) and the message is searched again. For example, if you are looking
for a message with the key `com.myapp.model.Account.name.empty` (possibly while performing
domain model validation), then following keys will be used to lookup an appropriate
message (until first success):

    com.myapp.model.Account.name.empty
    myapp.model.Account.name.empty
    model.Account.name.empty
    Account.name.empty
    name.empty
    empty

Messages can also be formatted. We support both classic `MessageFormat` style
(you know, with `{0}`s in text and varargs) and parameters interpolation (key-value pairs
are passed as arguments to `fmt` method, each `{key}` in message is replaced by
corresponding value).

The cool thing about Circumflex Messages API is that it supports hot editing (without
the need of redeployment) with effective last-modified-timestamp-based cache.

For further information refer to [Circumflex API documentation](/api/2.0/circumflex-core/messages.scala).