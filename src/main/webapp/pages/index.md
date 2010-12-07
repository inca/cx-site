Circumflex unites several self-contained projects for quick and robust application
development using [Scala][] programming language.

  * [Circumflex Web Framework](#web)
  * [Circumflex ORM](#orm)
  * [Circumflex FreeMarker Helper](#ftl)
  * [Circumflex Markdown](#md)
  * [Circumflex Docco](#docco)
  * [Circumflex Maven Plugin](/plugin.html)

Each Circumflex project focuses on code quality, simplicity and consistency -- such
forgotten merits in todays race for features and enterprise panacea-like solutions.
We make every effort to keep [Circumflex codebase](/api) concise, elegant and balanced.

# Web Framework  {#web}

[Circumflex Web Framework](/web.html) is a DSL for quick web application development.

It is designed around the _route concept_. A route is an HTTP method with matching mechanism
and attached block. The application itself is essentially a sequential set of routes: they are
matched in the order they are defined, the first route that matches the request is invoked.

Here's a simple web application:

    class Main extends RequestRouter {                                    {.scala}
      get("/") = "Hello world!"
      get("/posts/:id") = "Post #" + uri("id")
      post("/form") = {
        // Do some work
        // . . .
        // Render FreeMarker template:
        ftl("/done.ftl")
      }
    }

Of course the capabilities of Web framework are not limited to responding to HTTP methods and
matching URLs. Check out the [Circumflex Web Framework page](/web.html) for detailed overview.

# Object-Relational Mapper {#orm}

What can possibly be better than designing domain model schema right inside your application
using a DSL which closely resembles data definition language of SQL databases?

    class Country extends Record[String, Country] {                       {.scala}
      val code = "code".VARCHAR(2).NOT_NULL.DEFAULT("'ch'")
      val name = "name".TEXT.NOT_NULL

      def cities = inverseMany(City.country)
      def relation = Country
      def PRIMARY_KEY = code
    }

    object Country extends Country with Table[String, Country]

    class City extends Record[Long, City] with SequenceGenerator[Long, City] {
      val id = "id".BIGINT.NOT_NULL.AUTO_INCREMENT
      val name = "name".TEXT
      val country = "country_code".TEXT.NOT_NULL
              .REFERENCES(Country)
              .ON_DELETE(CASCADE)
              .ON_UPDATE(CASCADE)

      def relation = City
      def PRIMARY_KEY = id
    }

    object City extends City with Table[Long, City]

But still it is nothing comparing to object-oriented querying:

    // Prepare the relations that will participate in queries:            {.scala}
    val ci = City as "ci"
    val co = Country as "co"
    // Select all cities of Switzerland, return Seq[City]:
    SELECT (ci.*) FROM (ci JOIN co) WHERE (co.code LIKE "ch") ORDER_BY (ci.name ASC) list
    // Select countries and count their cities, return Seq[(Option[Country], Option[Long])]:
    SELECT (co.* -> COUNT(ci.id)) FROM (co JOIN ci) GROUP_BY (co.*) list
    // Select countries with corresponding cities, return a sequence of alias maps:
    SELECT (co.* AS "country", ci.* AS "city") FROM (co JOIN ci) list

Circumflex ORM also features lazy and eager fetching strategies for associations, complex queries,
including subqueries of all kinds, data manipulation statements (`INSERT .. SELECT`, `UPDATE` and
`DELETE`), set operations between queries (`UNION`, `INTERSECT`, `EXCEPT`), transaction-scoped
and application-scoped caching with [Terracotta Ehcache][ehcache], xml data import, schema generation
with [Maven plugin](/plugin.html#schema) and other cute stuff for data-centric applications.

For more information, please check out the [Circumflex ORM page](/orm.html).

# Markdown  {#md}

The infamous text-to-html conversion tool for writers, [Markdown][], is now available for Scala
users with some extensions and improved performance. The usage is pretty simple:

    val html = Markdown(text)                                             {.scala}

You are welcome to try it [online](/.mdwn)!

# Freemarker  {#ftl}

Circumflex Freemarker module brings the power of the most advanced Java templating language,
[Freemarker][] to Scala. Due to the fact that Freemarker templates can effectively render any
possible content, the Freemarker is considered the main view technology for
[Circumflex Web Framework](#web).

# Docco  {#docco}

Circumflex Docco is a port of [Docco Project](http://jashkenas.github.com/docco) for Scala.
The ideas of documenting open-source Scala programs in Docco style are under evaluation for now,
but you still might want to try it and let us know, what you think about it.

# Why Circumflex? {#why}

  * Circumflex projects require minimum initial configuration, while still allowing
  developers to easily override defaults if necessary.
  * Circumflex projects are written in Scala. They have all the benefits of Scala.
  They run on the JVM. They are fast. They are concise.
  * Circumflex does not try to solve all the problems a developer might ever face.
  It maintains a minimal features set, allowing developers to choose the tools and libraries
  which best suit their particular needs.
  * Circumflex is designed to use the powers of the Apache Maven 2 software management
  platform. Adding Circumflex components to your project is a matter of few more lines
  in your `pom.xml`.
  * All Circumflex components are designed to maximize the ease-of-use and clarity of your code.
  The development process with Circumflex is intuitive and extremely productive. 
  * Circumflex is completely free, with a BSD-style [license](/license.html).

# Quick start  {#start}

## Use With Existing Projects  {#existing-projects}

If you already have a project and wish to use one of the Circumflex components, just
add the corresponding dependency to your project's `pom.xml`:

    <properties>                                                           {.xml}
      <cx.version><!-- desired version --></cx.version>
    </properties>
    <dependencies>
      <!-- Circumflex Web Framework -->
      <dependency>
        <groupId>ru.circumflex</groupId>
        <artifactId>circumflex-web</artifactId>
        <version>{cx.version}</version>
      </dependency>
      <!-- Circumflex ORM -->
      <dependency>
        <groupId>ru.circumflex</groupId>
        <artifactId>circumflex-orm</artifactId>
        <version>{cx.version}</version>
      </dependency>
      <!-- Circumflex Freemarker Views -->
      <dependency>
        <groupId>ru.circumflex</groupId>
        <artifactId>circumflex-ftl</artifactId>
        <version>{cx.version}</version>
      </dependency>
      <!-- Circumflex Markdown -->
      <dependency>
        <groupId>ru.circumflex</groupId>
        <artifactId>circumflex-md</artifactId>
        <version>{cx.version}</version>
      </dependency>
      <!-- Circumflex Docco -->
      <dependency>
        <groupId>ru.circumflex</groupId>
        <artifactId>circumflex-docco</artifactId>
        <version>{cx.version}</version>
      </dependency>
    </dependencies>

Note that all Circumflex components should share the same version. Check out the
[Central Maven Repository][m2-central] to determine the latest version of Circumflex.

## Create New Project  {#new-projects}

As soon as Circumflex is built, you are ready to create your first project. Change
to the directory where you store your projects, and run:

    $ mvn archetype:generate                                               {.no-highlight}

Choose the *circumflex-archetype* from your local catalog:

    Choose archetype:                                                      {.no-highlight}
    1: local -> circumflex-archetype (Circumflex Application Archetype)
    2: internal -> . . .
    Choose a number:  (1/2/3/ . . .) 17: : 1

Provide basic information about your project:

    Define value for groupId: : com.myapp                                  {.no-highlight}
    Define value for artifactId: : myapp
    Define value for version:  1.0-SNAPSHOT: : 1.0
    Define value for package:  com.myapp: :

After you confirm your choice, a simple Circumflex application will be created. To run
it, go to your project root (it matches the `artifactId` that you specified above)
and execute the following:

    $ mvn compile jetty:run                                                {.no-highlight}

The following lines indicate that your application is ready to serve requests:

    [INFO] Started Jetty Server                                            {.no-highlight}
    [INFO] Starting scanner at interval of 5 seconds.

Now you may visit your application at <http://localhost:8180>.

## Build From Sources  {#sources}

You can obtain the latest Circumflex sources at [GitHub][gh-cx]:

    $ git clone git://github.com/inca/circumflex.git                       {.no-highlight}

Circumflex, like all Scala applications, is compiled into Java VM bytecode. Make sure
that the latest [Java 6 SDK][jdk] is installed on your system.

Circumflex uses [Apache Maven 2][m2] for build management. If you don't already have
Maven 2, [install it][m2-install]. Note that some operating systems (e.g. Mac OS X
10.5 and higher) are shipped with Maven 2 by default. On some systems it is also
preferrable to install Maven 2 via package managers. For example, on Debian or Ubuntu
systems you can install Maven 2 by executing the following line:

    $ sudo apt-get install maven2                                          {.no-highlight}

If you are unfamiliar with Maven, you should probably read the [Maven in 5 Minutes][m2-5min]
article or [Getting Started Guide][m2-gsg].

Once you are ready to build, execute the following in the Circumflex root directory:

    $ mvn clean install                                                    {.no-highlight}

After the build has successfully finished, Circumflex with all its dependencies will
be available in your local Maven 2 repository (it may take a while to download
dependencies the first time).

## Build With SBT {#sbt}

An application skeleton for SBT has been kindly provided by
[andreyshikov](http://github.com/andreyshikov), it shows how to configure simple Circumflex
application to build with SBT.

You can clone it from <http://github.com/andreyshikov/circumflex-sbt-quickstart>.

# Contribute  {#contribute}

Circumflex is being actively developed. Our young project needs your help and support
to grow strong and mature. You can help the Circumflex project in following ways:

  * fork [Circumflex on GitHub][gh-cx] and take part in development;
  * report [issues][gh-issues];
  * fork [this site][gh-cx-site] and help us with documentation, FAQs, tutorials,
  examples and success stories;
  * blog about Circumflex and [let us know about it](/team.html);
  * contact [The Circumflex Team](/team.html) personally;
  * just use Circumflex in your development and have fun :)

We highly appreciate your help!

  [scala]: http://scala-lang.org
  [jdk]: http://java.sun.com/javase/downloads/index.jsp
  [m2]: http://maven.apache.org
  [m2-install]: http://maven.apache.org/download.html#Installation
  [m2-5min]: http://maven.apache.org/guides/getting-started/maven-in-five-minutes.html
  [m2-gsg]: http://maven.apache.org/guides/getting-started/index.html
  [m2-central]: http://repo2.maven.org/maven2/ru/circumflex/circumflex-parent
  [gh-cx]: http://github.com/inca/circumflex
  [gh-issues]: http://github.com/inca/circumflex/issues
  [gh-cx-site]: http://github.com/inca/cx-site
  [markdown]: http://daringfireball.net/projects/markdown/
  [freemarker]: http://freemarker.org
  [sinatra]: http://sinatrarb.com
  [ehcache]: http://ehcache.org
