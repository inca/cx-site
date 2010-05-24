Circumflex ORM   {#orm}
==============

Circumflex ORM is an [Object/Relational Mapping (ORM)][orm-wiki] framework for creating fast,
concise and efficient data-centric applications with elegant DSL.

The term [Object/Relational Mapping][orm-wiki] refers to the technique of mapping
a data representation from an object model to a relational data model. ORM tools may
significantly speed up development by eliminating boilerplates for common
[CRUD][crud-wiki] operations, making applications more portable by
incapsulating vendor-specific SQL dialects, providing object-oriented API for querying,
allowing transparent navigation between object associations and much more.

  [orm-wiki]: http://en.wikipedia.org/wiki/Object-relational_mapping
              "ORM definition on Wikipedia"
  [crud-wiki]: http://en.wikipedia.org/wiki/Create,_read,_update_and_delete
               "CRUD definition on Wikipedia"

## Installation & Configuration   {#install}

There's a couple of things you need to do in order to get started with Circumflex ORM.

First, make sure that `circumflex-orm-<version>.jar` is in the classpath. The easiest way
to do so is to add corresponding `dependency` to your `pom.xml`:

    lang:xml
    <properties>
      <cx.version><!-- desired version --></cx.version>
    </properties>
    <dependencies>
      <!-- Circumflex ORM -->
      <dependency>
        <groupId>ru.circumflex</groupId>
        <artifactId>circumflex-orm</artifactId>
        <version>{cx.version}</version>
      </dependency>
    </dependencies>

Second, configure database access by specifying following [configuration parameters](#cfg):

  * `orm.connection.driver` -- fully-qualified class name of JDBC Driver of your database vendor;
  * `orm.connection.url` -- URL for database communication (read the documentation of
  your database vendor for more information);
  * `orm.connection.username` and `orm.connection.password` -- database account data which will
  be used to obtain JDBC connections.

There are a couple of ways you can provide configuration parameters:

  * You can specify them in `cx.properties`:

        lang:no-highlight
        orm.connection.driver=org.postgresql.Driver
        orm.connection.url=jdbc:postgresql://localhost:5432/mydb
        orm.connection.username=myuser
        orm.connection.password=mypassword

    This file should be in the classpath, (typically in `/WEB-INF/classes` of your web application);
    if you use Maven, just place it into `src/main/resources` directory.

  * You can also specify them in your `pom.xml` and configure `maven-cx-plugin`:

        lang:xml
        <project xmlns="http://maven.apache.org/POM/4.0.0">
          <properties>
            <orm.connection.driver>org.postgresql.Driver</orm.connection.driver>
            <orm.connection.url>jdbc:postgresql://localhost:5432/mydb</orm.connection.url>
            <orm.connection.username>myuser</orm.connection.username>
            <orm.connection.password>mypassword</orm.connection.password>
          </properties>
        </project>

    Note that you should also add an execution for `cfg` goal of `maven-cx-plugin` to your
    `pom.xml`, see the [Circumflex Maven Plugin documentation](/plugin.html#cfg) for more details.

If you are writing a web application, configure `TransactionManagementListener` in your `web.xml`:

    lang:xml
    <web-app version="2.5">
      <listener>
        <listener-class>ru.circumflex.orm.TransactionManagementListener</listener-class>
      </listener>
    </web-app>

Note that there are different approaches to transaction demarcation in web applications.
Read [transaction demarcation](#demarcation) for more information.

### Imports   {#import}

All code examples assume that you have following `import` statement in code where necessary:

    lang:scala
    import ru.circumflex.orm._

## Central abstractions   {#abstractions}

Applications built with Circumflex ORM usually operate with following abstractions:

  * [`Record`](#record) -- wraps a row in a database `Table` or `View`, encapsulates the database
  access and adds domain logic on that data;
  * [`Relation`](#relation) -- encapsulates database object (`Table` or `View`) for
  corresponding `Record` and adds methods for [querying](#sql), [manipulating](#dml)
  and [validating](#validation) it's data;
  * `Field` -- corresponds to database column iside `Record`;
  * [`Association`](#association) -- links one type of `Record` with another, this relationship
  is expressed by foreign keys in the database;
  * `Query` -- communicates with database either for [data retrieval](#sql) or
  [data manipulation](#dml);
  * `SchemaObject` -- represents an abstract [database object](#aux) (such as trigger or
  stored procedure).

## Data definition   {#ddl}

The process of creating the domain model of application is refered to as *data definition*.
It usually involves following steps:

  * defining a [record](#record), a subclass of `Record`;
  * defining *fields* and [associations](#association) of the record;
  * cdefining relation, a companion object for the record subclassed from `Relation` (typically,
  more specific `Table` and `View` classes are subclassed);
  * adding [constraints](#constraint), [indexes](#index) and other [auxiliary database objects](#aux);
  * adding methods for [querying](#sql) and [manipulating](#dml) records;
  * specifying, how the record should be [validated](#validation).

### Records   {#record}

A record is definied by subclassing `Record` and supplying self-type as it's type parameter:

    lang:scala
    class Account extends Record[Account]

The body of record class should contain definitions of it's *fields*. A field should be an
immutable (`val`) member of record class, each field will correspond to a column in database table:

    lang:scala
    class Country extends Record[Country] {
      val code = "code" VARCHAR(2) DEFAULT("'ch'") NOT_NULL
      val name = "name" TEXT
    }

As the example shows, the syntax of field definition closely resembles classic DDL for generating database schema for tables. However, sometimes Scala compiler forces you to use dot-notation instead of delimiting method calls with spaces:

    lang:scala
    val name = "name".TEXT.NOT_NULL

The columns are generated with `NOT NULL` constraint by default, so `NOT_NULL` is used only for
clarity:

    lang:scala
    // following definitions are equivalent:
    val name = "name".TEXT.NOT_NULL
    val name = "name".TEXT

If you need a column without `NOT NULL` constraint, you should express this using `NULLABLE` method:

    lang:scala
    val optionalField = "optional".TEXT.NULLABLE

### Relations   {#relation}

### Constraints   {#constraint}

### Indexes   {#index}

### Associations   {#associaton}

### Validation   {#validation}

### Export Database Schema   {#export-schema}

## Querying   {#sql}

### Select Queries   {#select}

### Predicates   {#predicate}

### Projections   {#projection}

### Ordering   {#order-by}

### Grouping & Having   {#group-by}

### Limit & Offset   {#limit-offset}

## Data manipulation   {#dml}

### Insert, Update, Delete & Save   {#iuds}

### Insert-Select   {#insert-select}

### Bulk Update   {#update}

### Bulk Delete   {#delete}

## Criteria API   {#criteria}

## Advanced concepts   {#advanced}

### Transaction Demarcation   {#demarcation}

### Transaction-Scoped Cache   {#cache}

### Auxiliary Database Objects   {#aux}

### Dialects   {#dialect}

### Configuration Parameters   {#cfg}