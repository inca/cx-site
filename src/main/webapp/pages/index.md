Introducing Circumflex  {#intro}
======================

Circumflex is a set of software components for quick and robust application development
using [Scala][] programming language.

Circumflex consists of several separate projects:

  * [Circumflex Web Framework](#web)
  * [Circumflex ORM](#orm)
  * [Circumflex FreeMarker Views](#ftl)
  * [Circumflex Markdown](#md)
  * [Circumflex Docco](#docco)
  * [Circumflex Maven Plugin](/plugin.html)

## At a glance  {#glance}

All Circumflex components share the same phylosophy: the development process should be
natural and intuitive. They rely on Scala support for domain-specific languages that make
the development extremely efficient. And simple.

### Web Framework  {#web}

Here's a simple web application:

    lang:scala
    class Main extends RequestRouter {
      get("/") = "Hello world!"      // match GET /
      post("/form") = {              // match POST /form
        // do some work
        // . . .
        // render FreeMarker template
        ftl("/done.ftl")
      }
    }

Of course, the capabilities of Web framework are not limited to responding to methods and URLs.
Check out the [Circumflex Web Framework page](/web.html) for detailed overview.

### ORM  {#orm}

What can possibly be better than designing the domain model using the domain specific language
that closely resembles the data definition language of SQL databases?

    lang:scala
    class City extends Record[City] {
      val name = "name" TEXT
      val country = "country_id" REFERENCES(Country) ON_DELETE CASCADE ON_UPDATE CASCADE
      override def toString = name.getOrElse("Unknown")
    }

    object City extends Table[City]

    class Country extends Record[Country] {
      val code = "code" VARCHAR(2) DEFAULT("'ch'")
      val name = "name" TEXT
      def cities = inverse(City.country)
      override def toString = name.getOrElse("Unknown")
    }

    object Country extends Table[Country] {
      INDEX("country_code_idx", "LOWER(code)") USING "btree" UNIQUE
    }

But still it is nothing comparing to object-oriented querying:

    lang:scala
    // Prepare the relations that will participate in queries
    val ci = City as "ci"
    val co = Country as "co"
    // Select all russian cities
    SELECT (ci.*) FROM (ci JOIN co) WHERE (co.code LIKE "ru") ORDER_BY (ci.name ASC) list   // Seq[City]
    // Select countries with corresponding cities
    SELECT (co.*, ci.*) FROM (co JOIN ci) list                                              // Seq[(Country, City)]
    // Select countries and count their cities
    SELECT (co.*, COUNT(ci.id)) FROM (co JOIN ci) GROUP_BY (co.*) list                      // Seq[(Country, Int)]

Circumflex ORM also features lazy and eager fetching strategies for associations, complex queries,
including subqueries of all kinds, data manipulation statements (`INSERT .. SELECT`, `UPDATE` and
`DELETE`), set operations between queries (`UNION`, `INTERSECT`, `EXCEPT`),
transaction-scoped caching, xml data import, schema generation with Maven plugin and arbitrary projections.

For more information, please check out the [Circumflex ORM page](/orm.html).

### Markdown  {#md}

The infamous text-to-html conversion tool for writers, [Markdown][], is now available for Scala users
with some extensions and improved performance. The usage is pretty simple:

    lang:scala
    val html = Markdown(source)

### Freemarker  {#ftl}

Circumflex Freemarker module brings the power of the most advanced Java templating language,
[Freemarker][] to Scala. Due to the fact that Freemarker templates can effectively render any
possible content, the Freemarker is considered the main view technology for
[Circumflex Web Framework](#web).

### Docco  {#docco}

Circumflex Docco is a port of [Docco Project](http://jashkenas.github.com/docco) for Scala.
The ideas of documenting open-source Scala programs in Docco style are under evaluation for now,
but you still might want to try it and let us know, what you think about it.

## Why Circumflex? {#why}

  * Circumflex components require minimum initial configuration, while still allowing
  developers to easily override defaults if necessary.
  * Circumflex is based on Scala. It has all the benefits of Scala.
  It runs on JVM. It is fast. It is concise.
  * Circumflex does not try to solve all the problems the developer might ever face.
  It keeps minimal features set, allowing developers to choose the tools and libraries
  that best suit their particular needs.
  * Circumflex is designed to use the powers of Apache Maven 2 software management
  platform. Adding Circumflex components to your project is a matter of few more lines
  in your `pom.xml`.
  * All Circumflex components are designed for ease-of-use and clarity of your code.
  The development process with Circumflex is intuitive and extremely productive. 
  * Circumflex is completely free, with BSD-style [license](/license.html).

## Quick start

### Use with existing projects

If you already have a project and wish to use one of the Circumflex components, just
 add the corresponding dependency to your project's `pom.xml`:

    lang:xml
    <properties>
      <cx.version><!-- desired version --></cx.version>
    </properties>
    <dependencies>
      <!-- Circumflex Web Framework -->
      <dependency>
        <groupId>ru.circumflex</groupId>
        <artifactId>circumflex-core</artifactId>
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

### Create new project

As soon as Circumflex is built, you are ready to create your first project. Change
to the directory where you store your projects and run:

    lang:no-highlight
    $ mvn archetype:generate

Choose the **circumflex-archetype** from your local catalog:

    lang:no-highlight
    Choose archetype:
    1: local -> circumflex-archetype (Circumflex Application Archetype)
    2: internal -> . . .
    Choose a number:  (1/2/3/ . . .) 17: : 1

Provide basic information about your project:

    lang:no-highlight
    Define value for groupId: : com.myapp
    Define value for artifactId: : myapp
    Define value for version:  1.0-SNAPSHOT: : 1.0
    Define value for package:  com.myapp: :

After you confirm your choice, a simple Circumflex application will be created. To run
it, go to your project root (it matches `artifactId` that you have specified above)
and execute the following:

    lang:no-highlight
    $ mvn compile jetty:run

The following lines indicate that your application is ready to serve requests:

    lang:no-highlight
    [INFO] Started Jetty Server
    [INFO] Starting scanner at interval of 5 seconds.

Now you may visit your application at <http://localhost:8180>.

### Build from sources

You can obtain latest Circumflex sources at [GitHub][gh-cx]:

    lang:no-highlight
    $ git clone git://github.com/inca/circumflex.git

Circumflex, like all Scala applications, is compiled into Java VM bytecode. Make sure
that latest [Java 6 SDK][jdk] is installed on your system.

Circumflex uses [Apache Maven 2][m2] for build management. If you don't already have
Maven 2, [install it][m2-install]. Note, that some operating systems (e.g. Mac OS X
10.5 and higher) are shipped with Maven 2 by default. On some systems it is also
preferrable to install Maven 2 via package managers. For example, on Debian or Ubuntu
systems you may install Maven 2 by executing the following line:

    lang:no-highlight
    $ sudo apt-get install maven2

If you are unfamiliar with Maven, you should probably read the [Maven in 5 Minutes][m2-5min]
article or [Getting Started Guide][m2-gsg].

Once you are ready to build, execute the following in Circumflex root directory:

    lang:no-highlight
    $ mvn clean install

After the build has successfully finished, Circumflex with all it's dependencies will
be available in your local Maven 2 repository (it may take a while to download
dependencies the first time).

## Contribute

Circumflex is in active development stage. It is very young project and it needs your help and support to grow strong. You can help make Circumflex project better in following ways:

  * fork [Circumflex on GitHub][gh-cx] and take part in development;
  * report [issues][gh-issues];
  * fork [this site][gh-cx-site] and help us with documentation, FAQs, tutorials, examples and success stories;
  * blog about Circumflex and [let us know about it](/team);
  * contact [The Circumflex Team](/team) personally.

We would highly appreciate your help! 

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
