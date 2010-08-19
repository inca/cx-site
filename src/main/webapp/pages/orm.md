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

Note that there are different approaches to transaction demarcation in web applications, read more
in the [transaction demarcation](#transaction) section.

### Imports   {#import}

All code examples assume that you have following `import` statement in code where necessary:

    lang:scala
    import ru.circumflex.orm._

## Central abstractions   {#abstractions}

Applications built with Circumflex ORM usually operate on following abstractions:

  * [`Record`](#record) -- wraps a row in a database `Table` or `View`, encapsulates the database
  access and adds domain logic on that data;
  * [`Relation`](#relation) -- encapsulates database object (`Table` or `View`) for
  corresponding `Record` and adds methods for [querying](#sql), [manipulating](#dml)
  and [validating](#validation) it's data;
  * `Field` -- corresponds to database column inside of `Record`;
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
  * adding constraints, indexes and other [auxiliary database objects](#aux);
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

As the example shows, the syntax of field definition closely resembles classic DDL for generating
database schema for tables: you specify the column name with `String`, then you call one of the
methods to create a field of certain type, then you optionally call one of methods that change the
definition of target column.

Generally, spaces may be used to delimit method calls and improve readability of column definitions.
However, sometimes Scala compiler forces you to use dot-notation:

    lang:scala
    val name = "name".TEXT.NOT_NULL

Following methods are used to create field definitions:

<table width="100%">
  <thead>
  <tr>
    <th>Method</th>
    <th>Default SQL type</th>
    <th>Scala type</th>
    <th>Implementing class</th>
  </tr>
  </thead>
  <tbody>
  <tr>
    <td><code>INTEGER</code></td>
    <td><code>INTEGER</code></td>
    <td><code>Int</code></td>
    <td><code>IntField</code></td>
  </tr>
  <tr>
    <td><code>BIGINT</code></td>
    <td><code>BIGINT</code></td>
    <td><code>Long</code></td>
    <td><code>LongField</code></td>
  </tr>
  <tr>
    <td><code>NUMERIC(precision: Int, scale: Int)</code></td>
    <td><code>NUMERIC(p, s)</code></td>
    <td><code>Double</code></td>
    <td><code>DoubleField</code></td>
  </tr>
  <tr>
    <td><code>TEXT</code></td>
    <td><code>TEXT</code></td>
    <td><code>String</code></td>
    <td><code>StringField</code></td>
  </tr>
  <tr>
    <td><code>VARCHAR(length: Int)</code></td>
    <td><code>VARCHAR(l)</code></td>
    <td><code>String</code></td>
    <td><code>StringField</code></td>
  </tr>
  <tr>
    <td><code>BOOLEAN</code></td>
    <td><code>BOOLEAN</code></td>
    <td><code>Boolean</code></td>
    <td><code>BooleanField</code></td>
  </tr>
  <tr>
    <td><code>DATE</code></td>
    <td><code>DATE</code></td>
    <td><code>java.lang.Date</code></td>
    <td><code>DateField</code></td>
  </tr>
  <tr>
    <td><code>TIME</code></td>
    <td><code>TIME</code></td>
    <td><code>java.lang.Date</code></td>
    <td><code>DateField</code></td>
  </tr>
  <tr>
    <td><code>TIMESTAMP</code></td>
    <td><code>TIMESTAMP</code></td>
    <td><code>java.lang.Date</code></td>
    <td><code>DateField</code></td>
  </tr>
  </tbody>
</table>

In the table above the default SQL types show the types defined in default [dialect](#dialect),
which can be overriden in vendor-specific dialect. Besides it is possible to define a field with
custom SQL type using the `field(name: String, sqlType: String)` method:

    lang:scala
    val myCustomField = field("custom", "NVARCHAR(32)").NOT_NULL

The columns are generated with `NOT NULL` constraint by default, so `NOT_NULL` call can be omitted:

    lang:scala
    // following definitions are equivalent:
    val name = "name".TEXT.NOT_NULL
    val name = "name".TEXT

If you need a column without `NOT NULL` constraint, you should express this using `NULLABLE` method:

    lang:scala
    val optionalField = "optional".TEXT.NULLABLE

Each record also has an implicit auto-incremented primary key field -- `id`. It is used to look up
records in [transaction-scoped cache](#cache), for various [data manipulation queries](#dml)
and other things. A record is refered to *transient* if it's `id` value is empty, otherwise it is
considered *persistent*.

Fields operate with values. You may set the value of a field:

    lang:scala
    val age = "age" INTEGER
    // following statements are equivalent:
    age := 25
    age.setValue(25)
    age() = 25

You may also retrieve the value of a field:

    lang:scala
    // following statements are equivalent:
    age()           // 25
    age.apply       // 25
    age.getValue    // 25

You may also use the `get` method for pattern matching:

    lang:scala
    age.get match {
      case Some(a) => ...
      case None => ...
    }

Or use the `getOrElse` method, which returns specified `default` instead of `null`:

    lang:scala
    age.getOrElse(18)

There are also shortcut methods for setting or checking the `null` value:

    lang:scala
    // set null:
    age.NULL_!
    age.setNull
    // check, if value is null:
    if (age.NULL_?) ...
    if (age.empty_?) ...

You may specify the default expression for a field:

    lang:scala
    class Circle extends Record[Circle] {
      val radius = "radius".NUMERIC
      val square = "square".NUMERIC.DEFAULT("PI() * (radius ^ 2)")
    }

If a record is inserted and the field with default expression is empty, then it's value will be
generated by the database.

You can also create a single-column unique constraint using the `UNIQUE` method:

    lang:scala
    val login = "login".VARCHAR(64).NOT_NULL.UNIQUE

You should place domain-specific logic inside record classes. The following example shows the most
trivial case: overriding `toString` and providing alternative constructor:

    lang:scala
    class Country extends Record[Country] {
      // Constructor shortcuts
      def this(code: String, name: String) = {
        this()
        this.code := code
        this.name := name
      }
      // Fields
      val code = "code" VARCHAR(2) DEFAULT("'ch'")
      val name = "name" TEXT
      // Miscellaneous
      override def toString = name.getOrElse("Unknown")
    }

### Relations   {#relation}

The relation is defined as a companion object of corresponding [record](#record) subclassed from
either `Table` or `View`:

    lang:scala
    object Country extends Table[Country]

You can place the definitions of constraints and indexes inside the body of relation:

    lang:scala
    object Country extends Table[Country] {
      // create a named UNIQUE constraint:
      CONSTRAINT "code_uniq" UNIQUE(this.code)   // relations are converted to records implicitly
      // create a UNIQUE constraint with default name:
      UNIQUE(this.code)
      // create a named CHECK constraint:
      CONSTRAINT "code_chk" CHECK("code IN ('ch', 'us', 'uk', 'fr', 'es', 'it', 'pt')")
      // create a named FOREIGN KEY constraint:
      CONSTRAINT "eurozone_code_fkey" FOREIGN_KEY(EuroZone, this.code -> EuroZone.code)
      // create a FOREIGN KEY constraint with default name:
      FOREIGN_KEY(EuroZone, this.code -> EuroZone.code).ON_DELETE(CASCADE)
      // create an index:
      INDEX("country_code_idx", "LOWER(code)") USING "btree" UNIQUE
    }

The relation object is also the right place for various querying methods:

    lang:scala
    object User extends Table[User] {
      def byLogin(l: String): Option[User] = criteria.add(this.login LIKE l).unique
    }

See [querying](#sql), [data manipulation](#dml) and [Criteria API](#criteria) sections for
more information.

### Associations   {#association}

An *association* provides a way to link one [relation](#relation) with another.

    lang:scala
    class City extends Record[City] {
      val country = "country_id" REFERENCES(Country) ON_DELETE CASCADE ON_UPDATE NO_ACTION
    }

As the example above shows, the syntax for association definition is similar to fields definition,
except that the `REFERENCES(relation: Relation[R])` method is used. Associations also implicitly
add foreign key constraint to table's definition, so the cascading actions can be specified by
invoking `ON_DELETE` and `ON_UPDATE` with one of the following arguments:

  * `NO_ACTION` (default),
  * `CASCADE`,
  * `RESTRICT`,
  * `SET_NULL`,
  * `SET_DEFAULT`.

Associations are directed: the relation that owns an association is often refered to as a
*child relation*, while the relation to which an associations references is often refered to
as a *parent relation*.

Like with regular field, you can set an retrieve the association's value:

    lang:scala
    // set the value
    country := russia
    country() = russia
    country.setValue(russia)
    // retrieve the value
    country()
    country.apply
    country.getValue
    // pattern match the value
    country.get match {
      case Some(c: Country) =>
      case None =>
    }
    // get or default
    country.getOrElse(new Country)
    // set null
    country.NULL_!
    // check for null
    country.NULL_?

An association's value is initilialized the first time you access it inside a persistent
[record](#record). This technique is usually refered to as *lazy initialization* or
*lazy fetching*:

    lang:scala
    val c = new City
    c.id := 16
    c.country()   // a SELECT query is executed to retrieve a Country
                  // for the City with id = 16
    c.country()   // further selects are not issued

The other side of association can optionally define an *inverse association* using following syntax:

    lang:scala
    class Country extends Record[Country] {
      val cities = inverse(City.country)
    }

Inverse associations are not represented by field in their relation, they are initialized by
issuing the `SELECT` statement against child relation:

    lang:scala
    val c = new Country
    c.id := 5
    c.cities()   // a SELECT query is executed to retrieve a set of City objects
                 // which have country_id = 5
    c.cities()   // further selects are not issued

You can also perform [association prefetching](#prefetch) for both straight and inverse
associations, using the [Criteria API](#criteria).

Note that associations hold their state in [transaction-scoped cache](#cache), it is invalidated
by any [data manipulation](#dml) statement or [transaction control](#transaction) command.

### Validation   {#validation}

A record can be optionally validated before it is saved into database.

The validation is performed using one or more *validators*, functions which take a `Record`
and return `Option[ValidationError]`: `None` if validation succeeds or `Some[ValidationError]`
otherwise. They are added to the `validation` object inside [relation](#relation):

    lang:scala
    object Country extends Table[Country] {
      validation.add(r => ...)
          .add(r => ...)
    }

There are several predefined validators available for your convenience:

    lang:scala
    class Country extends Record[Country] {
      val code = "code" VARCHAR(2) DEFAULT("'ch'")
    }

    object Country extends Table[Country] {
      validation.notNull(_.code)
          .notEmpty(_.code)
          .pattern(_.code, "(?i:[a-z]{2})")
    }

A record is validated when either `validate` or `validate_!` is invoked.
The first one returns `Option[ValidationErrors]`:

    lang:scala
    rec.validate match {
      case None => ...            // validation succeeded
      case Some(errors) => ...    // validation failed
    }

The second one does not return anything, but throws `ValidationException` if validation fails.

`ValidationErrors` is a convenient wrapper around `Seq[ValidationError]` which allows to
look up different errors by `source` (or it's part).

The `validate_!` method is also called when a record is being saved into database, read
more in [Insert, Update & Delete](#iud) section.

Each `ValidationError` could be resolved into a message from
[Circumflex `Messages` helper](/web.html#msg).
Following members of `ValidationError` are involved in message resolution:

  * `source` describes a place where error occured, most obvious field-based validators return
  `ValidationError` instances with field's `uuid` as their source;
  * `errorKey` describes the nature of the error, for example, `"null"` for `notNull` validator,
  or `"empty"` for `notEmpty` validator;
  * `params` provide additional information about validation, these params are
  [interpolated](/web.html#msg) inside resolved message.

The `toMsg` method resolves the message:

  * first, it tries to resolve a message with following key: `source + "." + errorKey`;
  * if no such message exist in the `Messages` bundle, it removes the part of the key until the
  first dot (`.`) and then tries again;
  * if no message found, it simply returns `errorKey`;
  * finally, the `params` are interpolated into the resolved message.

Let's take a look at example. First, let's define a simple model with validation:

    lang:scala
    package com.myapp.model

    class Country extends Record[Country] {
      def this(code: String) = {
        this()
        this.code := code
      }
      val code = "code" VARCHAR(2) DEFAULT("'ch'")
    }

    object Country extends Table[Country] {
      validation.notNull(_.code)
          .notEmpty(_.code)
          .pattern(_.code, "(?i:[a-z]{2})")
    }

Now let's provide some messages for validators:

    lang:no-highlight
    # Messages.properties
    Country.code.null=Null value in country code is not allowed.
    Country.code.empty=Empty value is country code is not allowed.
    Country.code.pattern=The value {value} doesn't look like a valid country code.

Finally, let's play with them a bit:

    lang:scala
    val c = new Country
    c.validate
    // Some(com.myapp.model.Country.code.null)
    c.code := "11"
    c.validate
    // Some(com.myapp.model.Country.code.pattern)
    c.validate.get.apply(0).toMsg
    // "The value 11 doesn't look like a valid country code."
    c.code := "ch"
    c.validate
    // None

It is also fairly easy to implement custom validators. Following example shows a validator
for checking unique email addresses:

    lang:scala
    object Account extends Table[Account] {
      validation.add(r => criteria
          .add(r.email EQ r.email())
          .unique
          .map(a => new ValidationError(r.email.uuid, "unique")))
    }

### Exporting Database Schema   {#export-schema}

You can use `DDLUnit` to create or drop database objects programmaticaly:

    lang:scala
    val ddl = new DDLUnit(Country, City)
    // drop objects
    ddl.drop
    // create objects
    ddl.create
    // drop and then create objects
    ddl.dropCreate

`DDLUnit` creates objects in the following order:

  * preliminary [auxiliary objects](#aux);
  * tables;
  * constraints;
  * views;
  * posterior [auxiliary objects](#aux).

Respectively, drop script works with objects in a reverse order.

After the execution, `DDLUnit` produces `messages`: `InfoMsg` for succeeded statements,
`ErrorMsg` for failed ones. Here's the example:

    lang:scala
    ddl.messages(0).sql
    // CREATE TABLE public.country (
    //   id BIGINT NOT NULL DEFAULT NEXTVAL('public.country_id_seq'),
    //   code VARCHAR(2) NOT NULL DEFAULT 'ch',
    //   name TEXT NOT NULL,
    //   PRIMARY KEY (id))
    ddl.messages(0).body
    // CREATE TABLE public.country: OK

You can also setup `maven-cx-plugin` to export the schema for your Maven project within a
build profile. Read more on [Circumflex Maven Plugin page](/plugin.html#schema).

## Querying   {#sql}

A precise request for information retrieval from database is often refered to as *query*.
There are various ways you can query your data with Circumflex ORM:

  * using [select queries](#select), a neat object-oriented DSL for retrieving [records](#record)
  as well as arbitrary [projections](#projection) with SQL-like syntax;
  * using the [Criteria API](#criteria), an alternative DSL for retrieving [records](#record)
  with associations prefetching capabilities;
  * using [native queries](#native) for executing vendor-specific queries for
  [records](#record) or arbitrary [projections](#projection).

All data retrieval queries derive from the `SQLQuery[T]` class. It defines following methods
for query execution:

  * `list()` executes a query and returns `Seq[T]`;
  * `unique()` executes a query and returns `Option[T]`, an exception is thrown if more than one
  row is returned from database;
  * `resultSet[A](actions: ResultSet => A)` executes a query and passes JDBC `ResultSet` object
  to specified `actions` function, the result is determined by that function.

### Select Queries   {#select}

Select queries are used to retrieve [records](#record) or arbitrary [projections](#projection)
with neat object-oriented DSL which closely resembles SQL syntax:

    lang:scala
    // prepare relation nodes which will participate in query:
    val co = Country AS "co"
    val ci = City AS "ci"
    // prepare a query:
    val q = SELECT (co.*) FROM (co JOIN ci) WHERE (ci.name LIKE "Moscow) ORDER_BY (co.name ASC)
    // execute a query:
    q.list    // returns Seq[Country]

The `Select` class provides functionality for select queries. It has following structure:

  * [`SELECT` clause](#projection) -- specifies a [projection](#projection) which determines
  the actual result of query execution;
  * [`FROM` clause](#node) -- specifies [relation nodes](#node) which will participate in query;
  * [`WHERE` clause](#predicate) -- specifies a [predicate](#predicate) which will be used by
  database to filter the records in result set;
  * [`ORDER_BY` clause](#order-by) -- tells database how the result set should be
  [sorted](#order-by);
  * [`GROUP_BY` clause](#group-by) -- specifies a subset of [projections](#projection) which will
  be used by database for [grouping](#group-by);
  * [`HAVING` clause](#group-by) -- specifies additional [predicate](#predicate) which will be
  applied by database after [grouping](#group-by);
  * [`LIMIT` clause and `OFFSET` clause](#limit-offset) -- tell database to return a subset of
  result set and specify it's boundaries;
  * [set operations](#set-ops) -- allow to combine the results of two or more [SQL queries](#sql).

### Relation Nodes   {#node}

*Relation node* wraps a [`Relation`](#relation) with an `alias` so that it can be a part of
`FROM` clause of database query.

Relation nodes are represented by the `RelationNode` class, they are created by calling the
`AS` method of [`Relation`](#relation):

    lang:scala
    val co = Country AS "co"

Relation nodes can be organized into *query trees* using [joins](#join).

### Projections   {#projection}

*Projection* reflects the type of data returned by query. Generally, it consists of expression
which can be understood in the `SELECT` clause of database and a logic to translate the
corresponding part of result set into specific type.

Projections are represented by the `Projection[T]` trait, where `T` denotes to the type of objects
which should be read from result set. Projections which only read from single database column
are refered to as *atomic projections*, they are subclassed from the `AtomicProjection` trait.
Projections which span across multiple database columns are refered to as *composite projections*,
they are subclassed from the `CompositeProjection` trait and consist of one or more
`subProjections`.

The most popular projection is `RecordProjection`, it is designed to retrieve [records](#record):

    lang:scala
    val co = Country AS "co"
    (SELECT (co.*) FROM co).list    // returns Seq[Country]

As the example above shows, the `*` method of [`RelationNode`](#node) returns a `RecordProjection`
instance which corresponds to the [record](#record) class of node.

You can also query single fields of [records](#record), `Field` is converted to
`FieldProjection` implicitly:

    lang:scala
    val co = Country AS "co"
    (SELECT (co.id) FROM co).list      // returns Seq[Long]
    (SELECT (co.name) FROM co).list    // returns Seq[String]

Another useful projection type is `Tuple<X>Projection`, where `<X>` is the size of expected tuple
(currently Circumflex ORM provides support for up to `Tuple10Projection`), `Tuple<X>`
of `Projection` is converted to `Tuple<X>Projection` implicitly:

    lang:scala
    val co = Country AS "co"
    val ci = City AS "ci"
    (SELECT (ci.*, co.*) FROM (co JOIN ci)).list    // returns Seq[(City, Country)]

You can even use arbitrary expression which your database understands as long as you specify
the expected type:

    lang:scala
    SELECT(expr[java.util.Date]("current_timestamp")).unique   // returns Option[java.util.Date]

There are also some predefined projection helpers for your convenience:

  * `COUNT`;
  * `COUNT_DISTINCT`;
  * `MAX`;
  * `MIN`;
  * `SUM`;
  * `AVG`.

You can easily implement your own projection helper. For example, you use SQL `substring` function
a lot and you want to be able to select substrings of your record's text fields. Here's the code
you should place somewhere in your library (or utility singleton):

    lang:scala
    object MyOrmUtils {
      def SUBSTR(f: TextField, from: Int = 0, length: Int = 0) = {
        var sql = "substring(" + f.name
        if (from > 0) sql += " from " + from
        if (length > 0) sql += " for " + length
        sql += ")"
        new ExpressionProjection[String](sql)
      }
    }

And here's the code to use it:

    lang:scala
    import MyOrmUtils._
    val co = Country AS "co"
    (SELECT (SUBSTR(co.code, 1, 1)) FROM co).list    // returns Seq[String]

### Predicates   {#predicate}

*Predicate* is a parameterized expression which is resolved by database into a boolean-value
function. Generally, predicates are used inside `WHERE` or `HAVING` clauses of SQL queries
to filter the rows in result set.

Predicates are represented by the `Predicate` class. The easiest way to compose a `Predicate`
instance is to use implicit conversion from `String` or `Field` to `SimpleExpressionHelper`
and call one of it's methods:

    lang:scala
    val co = Country AS "co"
    SELECT (co.*) FROM co WHERE (co.name LIKE "Switz%")

Following helper methods are available in `SimpleExpressionHelper`:

<table width="100%">
  <thead>
    <tr>
      <th>Group</th>
      <th>Method</th>
      <th>SQL equivalent</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="7">Comparison operators</td>
      <td><code>EQ(value: Any)</code></td>
      <td><code>= ?</code></td>
    </tr>
    <tr>
      <td><code>NE(value: Any)</code></td>
      <td><code>&lt;&gt; ?</code></td>
    </tr>
    <tr>
      <td><code>GT(value: Any)</code></td>
      <td><code>&gt; ?</code></td>
    </tr>
    <tr>
      <td><code>GE(value: Any)</code></td>
      <td><code>&gt;= ?</code></td>
    </tr>
    <tr>
      <td><code>LT(value: Any)</code></td>
      <td><code>&lt; ?</code></td>
    </tr>
    <tr>
      <td><code>LE(value: Any)</code></td>
      <td><code>&lt;= ?</code></td>
    </tr>
    <tr>
      <td><code>BETWEEN(lower: Any, upper: Any)</code></td>
      <td><code>BETWEEN ? AND ?</code></td>
    </tr>
    <tr>
      <td rowspan="2">Null handling</td>
      <td><code>IS_NULL</code></td>
      <td><code>IS NULL</code></td>
    </tr>
    <tr>
      <td><code>IS_NOT_NULL</code></td>
      <td><code>IS NOT NULL</code></td>
    </tr>
    <tr>
      <td rowspan="14">Subqueries</td>
      <td><code>IN(query: SQLQuery[_])</code></td>
      <td><code>IN (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>NOT_IN(query: SQLQuery[_])</code></td>
      <td><code>NOT IN (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>EQ_ALL(query: SQLQuery[_])</code></td>
      <td><code>= ALL (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>NE_ALL(query: SQLQuery[_])</code></td>
      <td><code>&lt;&gt; ALL (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>GT_ALL(query: SQLQuery[_])</code></td>
      <td><code>&gt; ALL (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>GE_ALL(query: SQLQuery[_])</code></td>
      <td><code>&gt;= ALL (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>LT_ALL(query: SQLQuery[_])</code></td>
      <td><code>&lt; ALL (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>LE_ALL(query: SQLQuery[_])</code></td>
      <td><code>&lt;= ALL (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>EQ_SOME(query: SQLQuery[_])</code></td>
      <td><code>= SOME (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>NE_SOME(query: SQLQuery[_])</code></td>
      <td><code>&lt;&gt; SOME (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>GT_SOME(query: SQLQuery[_])</code></td>
      <td><code>&gt; SOME (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>GE_SOME(query: SQLQuery[_])</code></td>
      <td><code>&gt;= SOME (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>LT_SOME(query: SQLQuery[_])</code></td>
      <td><code>&lt; SOME (SELECT ...)</code></td>
    </tr>
    <tr>
      <td><code>LE_SOME(query: SQLQuery[_])</code></td>
      <td><code>&lt;= SOME (SELECT ...)</code></td>
    </tr>
    <tr>
      <td rowspan="3">Miscellaneous</td>
      <td><code>LIKE(value: Any)</code></td>
      <td><code>LIKE ?</code></td>
    </tr>
    <tr>
      <td><code>ILIKE(value: Any)</code></td>
      <td><code>ILIKE ?</code></td>
    </tr>
    <tr>
      <td><code>IN(params: Any*)</code></td>
      <td><code>IN (?, ?, ...)</code></td>
    </tr>
  </tbody>
</table>

You can combine several predicates into `AggregatePredicate` using either `OR` or `AND` methods:

    lang:scala
    AND(co.name LIKE "Switz%", co.code EQ "ch")
    // or in infix notation:
    (co.name LIKE "Switz%") OR (co.code EQ "ch")

You can negotiate a predicate using the `NOT` method:

    lang:scala
    NOT(co.name LIKE "Switz%")

`String` values are implicitly converted into `SimpleExpression` predicate without parameters:

    lang:scala
    val co = Country AS "co"
    SELECT (co.*) FROM co WHERE ("co.code like 'ch'")

You can also use `prepareExpr` to compose a custom expression with parameters:

    lang:scala
    prepareExpr("co.name like :name or co.code like :code", "name" -> "Switz%", "code" -> "ch")

### Ordering   {#order-by}

Ordering expressions appear in `ORDER_BY` clause of `Select`, they determine how rows in
result set will be sorted. The easiest way to specify ordering expressions is to use implicit
convertions from `String` or `Field` into `Order`:

    lang:scala
    val co = Country AS "co"
    SELECT (co.*) FROM co ORDER_BY (co.name)

You can also add either `ASC` or `DESC` ordering specificator to explicitly set the direction of
sorting:

    lang:scala
    val co = Country AS "co"
    SELECT (co.*) FROM co ORDER_BY (co.name ASC)

If no specificator given, ascending sorting is assumed by default.

### Joins   {#join}

*Joins* are used to combine records from two or more relations within a query.

Joins concept is a part of [relational algebra][rel-algebra-wiki]. If you are not familiar with
joins in relational databases, consider spending some time to learn a bit about them. A good place
to start will be the [Join_(SQL) article on Wikipedia][joins-wiki].

Joins allow you to build queries which span across several associated relations:

    lang:scala
    val co = Country AS "co"
    val ci = City AS "ci"
    // find cities by the name of their corresponding countries:
    SELECT (ci.*) FROM (ci JOIN co) WHERE (co.name LIKE 'Switz%')

As the example above shows, joins are intended used in the `FROM` clause of query.
The result of calling the `JOIN` method is an instance of `JoinNode` class:

    lang:scala
    val co2ci = (Country AS "co") JOIN (City AS "ci")   // JoinNode[Country, City]

Every `JoinNode` has it's left side and right side. `co JOIN ci` is **not** equivalent to
`ci JOIN co`.

#### Left Associativity    {#joins-left-ass}

An important thing to know is that the join operation is **left-associative**: if join
is applied to `JoinNode` instance, the operation will be delegated to the `left` side
of `JoinNode`.

To illustrate this, let's take three associated tables, `Country`, `City` and `Street`:

    lang:scala
    val co = Country AS "co"
    val ci = City AS "ci"
    val st = Street AS "st"

We want to join them in following order: `Country` -> (`City` -> `Street`).
Since join operation is left-associative, we need extra parentheses:

    lang:scala
    co JOIN (ci JOIN st)

Now let's join the same tables in following order: (`City` -> `Street`) -> `Country`. In this
case the parentheses can be omitted:

    lang:scala
    ci JOIN st JOIN co

#### Joining Predicate    {#joins-predicate}

You can specify the *joining predicate* (the `ON` subclause of SQL joins) -- it will be used as
a joining condition by database:

    lang:scala
    (Country AS "co").JOIN(City AS "ci", "co.id = ci.country_id")

#### Automatic Joins    {#joins-auto}

If you do not specify joining predicate explicitly, Circumflex ORM will try to determine it
by searching the [associations](#association) between relations.
Let's say we have two associated relations:

    lang:scala
    class Country extends Record[Country]
    object Country extends Table[Country]
    class City extends Record[City] {
      val country = "country_id" REFERENCES Country ON_DELETE CASCADE
    }
    object City extends Table[City]

We can use implicit joins between `Country` and `City`:

    lang:scala
    Country AS "co" JOIN (City AS "ci")
    // country AS co LEFT JOIN city AS ci ON ci.country_id = co.id
    City AS "ci" JOIN (Country AS "co")
    // city AS ci LEFT JOIN country AS co ON ci.country_id = co.id

#### Join Types    {#joins-type}

Like in SQL, joins can be of several types. Depending on the type of join, rows which do not
match the joining predicate will be eliminated from one of the sides of join. Following join
types are available:

  * `INNER` joins eliminate unmatched rows from both sides;
  * `LEFT` joins return all matched rows plus one copy for each row in the left side relation
  for which there was no matching right-hand row (extended with `NULL`s on the right);
  * `RIGHT` joins, conversely, return all matched rows plus one copy for each row in the right side
  relation for which there was no matching right-hand row (extended with `NULL`s on the left);
  * `FULL` joins return all the joined rows, plus one row for each unmatched left-hand row
  (extended with `NULL`s on the right), plus one row for each unmatched right-hand row
  (extended with `NULL`s on the left).;
  * cross joins are achieved by passing multiple `RelationNode` arguments to `FROM`, they produce
   the Cartesian product of records, no join conditions are applied to them.

If no join type specified explicitly, `LEFT` join is assumed by default.

You can specify the type of join by passing an argument to the `JOIN` method:

    lang:scala
    (Country AS "co").JOIN(City AS "ci", INNER)

Or you may call one of specific methods instead:

    lang:scala
    Country AS "co" INNER_JOIN (City AS "ci")
    Country AS "co" LEFT_JOIN (City AS "ci")
    Country AS "co" RIGHT_JOIN (City AS "ci")
    Country AS "co" FULL_JOIN (City AS "ci")

### Grouping & Having   {#group-by}

A query can optionally condense into a single row all selected rows that share the same value for
a subset of query [projections](#projection). Such queries are often refered to as *grouping queries*
and the projections are usually refered to as *grouping projections*.

Grouping queries are built using the `GROUP_BY` clause:

    lang:scala
    val co = Country AS "co"
    SELECT (co.*) FROM co GROUP_BY (co.*)

As the example above shows, grouping projections are specified as arguments to the `GROUP_BY`
method.

Grouping queries are often used in conjunction with aggregate functions. If aggregate functions
are used, they are computed across all rows making up each group, producing separate value for
each group, whereas without `GROUP_BY` an aggregate produces a single value computed across all
the selected rows:

    lang:scala
    val co = Country AS "co"
    val ci = City AS "ci"
    // how many cities correspond to each selected country?
    SELECT (co.*, COUNT(ci.id)) FROM (co JOIN ci) GROUP_BY (co.*)

Groups can be optionally filtered using the `HAVING` clause. It accepts a [predicate](#predicate):

    lang:scala
    SELECT (co.*, COUNT(ci.id)) FROM (co JOIN ci) GROUP_BY (co.*) HAVING (co.code LIKE "c_")

Note that `HAVING` is different from `WHERE`: `WHERE` filters individual rows before the
application of `GROUP_BY`, while `HAVING` filters group rows created by `GROUP_BY`.

### Limit & Offset   {#limit-offset}

The `LIMIT` clause specifies the maximum number of rows a query will return:

    lang:scala
    // select 10 first countries:
    SELECT (co.*) FROM co LIMIT 10

The `OFFSET` clause specifies the number of rows to skip before starting to return results.
When both are specified, the amount of rows specified in the `OFFSET` clause is skipped before
starting to count the maximum amount of returned rows specified in the `LIMIT` clause:

    lang:scala
    // select 5 countries starting from 10th:
    SELECT (co.*) FROM co LIMIT 5 OFFSET 10

Note that query planners in database engines often take `LIMIT` and `OFFSET` into account when
generating a query plan, so you are very likely to get different row orders for different
`LIMIT`/`OFFSET` values. Thus, you should use explicit [ordering](#order-by) to achieve
consistent and predictable results when selecting different subsets of a query result with
`LIMIT`/`OFFSET`.

### Union, Intersect & Except   {#set-ops}

Most database engines allow to comine the results of two queries using the *set operations*.
Following set operations are available:

  * `UNION` -- appends the result of one query to another, eliminating duplicate rows from
  its result;
  * `UNION_ALL` -- same as `UNION`, but leaves duplicate rows in result set;
  * `INTERSECT` -- returns all rows that are in the result of both queries, duplicate rows are
  eliminated;
  * `INTERSECT_ALL` -- same as `INTERSECT`, but no duplicate rows are eliminated;
  * `EXCEPT` -- returns all rows that are in the result of left-hand query, but not in the result
  of right-hand query; again, the duplicates are eliminated;
  * `EXCEPT_ALL` -- same as `EXCEPT`, but duplicates are left in the result set.

The syntax for using set operations is:

    lang:scala
    // select the names of both countries and cities in a single result set:
    SELECT (co.name) FROM co UNION (SELECT (ci.name) FROM ci)

Set operations can also be nested and chained:

    lang:scala
    q1 INTERSECT q2 EXCEPT q3
    (q1 UNION q2) INTERSECT q3

The queries combined using set operations should have matching [projections](#projection).
Following will **not** compile:

    lang:scala
    SELECT (co.*) FROM co UNION (SELECT (ci.*) FROM ci)

### Reusing Query Objects   {#query-reuse}

When working with data-centric applications, you often need the same query to be executed with
different parameters. The most obvious solution is to build `Query` objects dynamically:

    lang:scala
    object Country extends Table[Country] {
      def findByCode(code: String): Option[Country] = {
        val co = this AS "co"
        val q = SELECT (co.*) FROM co WHERE (co.code LIKE code)
        reutrn q.unique
      }
    }

However, you can use *named parameters* to reuse the same `Query` object:

    lang:scala
    object Country extends Table[Country] {
      val co = AS("co")
      val byCode = SELECT (co.*) FROM co WHERE (co.code LIKE ":code")
      def findByCode(c: String): Option[Country] = byCode.set("code", c).unique
    }

As the example above shows, named parameters are `String`s which start with colon (`:`).
You can also use `Symbol`s instead:

    lang:scala
    object Country extends Table[Country] {
      val co = AS("co")
      val byCode = SELECT (co.*) FROM co WHERE (co.code LIKE 'code)
      def findByCode(c: String): Option[Country] = byCode.set('code, c).unique
    }

There are several syntactic ways to use queries with named parameters:

    lang:scala
    // following lines are equivalent:
    byCode.set('code, c)
    byCode('code) = c
    // or with Strings instead of Symbols:
    byCode.set("code", c)
    byCode("code") = c

## Criteria API   {#criteria}

Most (if not all) of your data retrieval queries will be focused to retrieve only one type of
[records](#record). *Criteria API* aims to minimize your effort on writing such queries. Following
snippet shows three equivalents of the same query:

    lang:scala
    val co = Country AS "co"
    // Select query:
    val countries = SELECT (co.*) FROM (co) WHERE (co.name LIKE "Sw%") list
    // Criteria query:
    Country.criteria.add(Country.name LIKE "Sw%").list
    // or with RelationNode:
    co.criteria.add(co.name LIKE "Sw%").list

As you can see, `Criteria` queries are more compact because boilerplate `SELECT` and `FROM` clauses
are omitted.

But aside from shortening the syntax, Criteria API offers unique functionality --
[associations prefetching](#prefetch), which can greatly speed up your application when working
with graphs of associated objects.

The `Criteria[R]` object has following methods for execution:

  * `list()` executes a query and returns `Seq[R]`;
  * `unique()` executes a query and returns `Option[R]`, an exception is thrown if more than one
  row is returned from database;
  * `mkSelect` transforms a `Criteria` into the [`Select` query](#select);
  * `mkUpdate` transforms a `Criteria` into the [`Update` query](#update-delete);
  * `mkSelect` transforms a `Criteria` into the [`Delete` query](#update-delete);
  * `toString` shows query tree for debugging.

You can use [predicates](#predicate) to narrow the result set. Unlike [`Select` queries](#select),
predicates are added to `Criteria` object using the `add` method and then are assembled into the
conjunction:

    lang:scala
    co.criteria.add(co.name LIKE "Sw%").add(co.code LIKE "ch").list

You can apply [ordering](#order-by) using the `addOrder` method:

    lang:scala
    co.criteria.addOrder(co.name).addOrder(co.code).list

Also you can add one or more [associated](#association) [relations](#relation) to the query plan
using the `join` method so that you can specify constraints upon them:

    lang:scala
    val co = Country AS "co"
    val ci = City AS "ci"
    co.criteria.join(ci).add(ci.name LIKE "Lausanne").list

[Automatic joins](#joins-auto) are used to update query plan properly. There is no limitation on
quantity or depth of joined relations. However, some database vendors have limitations on maximum
size of queries or maximum amount of relations participating in a single query.

One serious limitation of Criteria API is that it does not support `LIMIT` and `OFFSET` clauses
due to the fact that [association prefetching](#prefetching) normally causes result set to yield
more than one row per record. You can still use `LIMIT` and `OFFSET` with
[SQL queries](#limit-offset);

### Prefetching Associations   {#prefetch}

When working with [associated](#association) [records](#record) you often need a whole graph of
associations to be fetched.

Normally associations are fetched eagerly first time they are accessed, but when it is done for
every record in a possibly big result set, it would result in significant performance degradation
(see the [n + 1 selects problem explained][n+1] blogpost).

With Criteria API you have an option to fetch as many associations as you want in a single query.
This technique is refered to as *associations prefetching* or *lazy fetching*.

To understand how associations prefetching works, let's take a look at the following domain model
sample:

    lang:scala
    class Country extends Record[Country] {
      val code = "code" VARCHAR(2) DEFAULT("'ch'")
      val name = "name" TEXT
      // inverse association:
      def cities = inverse(City.country)
    }

    object Country extends Table[Country]

    class City extends Record[City] {
      val name = "name" TEXT
      // straight association:
      val country = "country_id" REFERENCES(Country) ON_DELETE CASCADE ON_UPDATE CASCADE
    }

    object City extends Table[City]

You see two [relations](#relation), `Country` and `City`. Each city has one [associated](#association)
`country`, and, conversely, each country has a list of corresponding `cities`.

Now you wish to fetch all cities with their corresponding countries in a single query:

    lang:scala
    val cities = City.criteria.prefetch(City.country).list
    cities.foreach(c => println(c.country()))   // no selects issued

The example above shows the prefetching for straight associations. Same logic applies to reverse
associations prefetching, for example, fetching all countries with their corresponding cities:

    lang:scala
    val countries = Country.criteria.prefetch(City.country).list
    countries.foreach(c => println(c.cities()))   // no selects issued

Okay. Now we totally hear you saying: "How is that really possible?" -- so let's explain a bit.
Each `Criteria` object maintains it's own tree of associations, which is used to form the `FROM`
clause of the query (using [automatic left-joins](#joins-auto)) and, eventually, to parse the
result set. The data from result set is parsed into chunks and loaded into
[transaction-scoped cache](#cache), which is subsequently used by associations and inverse
associations to avoid unnecessary selects.

There is no limitation on quantity or depth of prefetches. However, some database vendors
have limitations on maximum size of queries or maximum amount of relations participating in a
single query.

## Data manipulation   {#dml}

Aside from information retrieval tasks, queries may be intended to change data in some way:

  * add new records;
  * update existing records (either partially or fully);
  * delete existing records.

Such queries are often refered to as *data manipulation queries*.

### Insert, Update & Delete   {#iud}

Circumflex ORM employs Active Record design pattern. Each `Record` has following data manipulation
methods which correspond to their SQL analogues:

  * `INSERT_!(fields: Field[_]*)` -- executes an SQL `INSERT` statement for the record, that is,
  persists that record into database table. You can optionally specify `fields` which will appear
  in the statement; if no `fields` specified, then only non-empty fields will be used (they will
  be populated with `NULL`s or default values by database).
  * `INSERT(fields: Field[_]*)` -- same as `INSERT_!`, but runs record [validation](#validation) before
  actual execution;
  * `UDPATE_!(fields: Field[_]*)` -- executes an SQL `UPDATE` statement for the record, that is,
  updates all record's fields (or only specified `fields`, if any). The record is being looked up
  by it's `id`, so this method does not make any sense with transient records.
  * `UPDATE(fields: Field[_]*)` -- same as `UPDATE_!`, but runs record [validation](#validation) before
  actual execution;
  * `DELETE_!()` -- executes an SQL `DELETE` statement for the record, that is, removes that record
  from database. The record is being looked up by it's `id`, so this method does not make any sense
  with transient records.

### Save   {#save}

Circumflex ORM provides higher abstraction for persisting records -- the `save_!` method.
It's algorithm is trivial:

  * if record is persistent (`id` is not empty), it is updated using the `update_!` method;
  * otherwise the `insert_!` method is called, which causes database to generate an `id` value
  for the record and to store the corresponding row; the record is then immediately selected from
  database using vendor-specific `LAST_INSERT_ID`-based [predicate](#predicate) -- this logic ensures
  that all fields are up-to-date with actual database row, which could be affected by trigger or
  something else at backend.

There is also a handy `save()` method, which runs record [validation](#validation) and then delegates
to `save_!()`.

We advise you to use the `save()` method whenever you want to insert or update a record.

### Bulk Queries   {#bulk}

Circumflex ORM provides support for the following bulk data manipulation queries:

  * [`INSERT ... SELECT`](#insert-select) -- inserts the result set of specified [`SQLQuery`](#sql)
  into specified [`Relation`](#relation);
  * [`UPDATE`](#update-delete) -- updates certain rows in specified [`Relation`](#relation);
  * [`DELETE`](#update-delete) -- removes certain rows from specified [`Relation`](#relation).

All data manipulation queries derive from the `DMLQuery` class. It defines a single method for
execution, `execute()`, which executes corresponding statement and returns the number of
affected rows.

Also note that each execution of any data manipulation query evicts all records from
[transaction-scoped cache](#cache).

#### Insert-Select   {#insert-select}

The `InsertSelect` query has following syntax:

    lang:scala
    val co = Country AS "co"
    INSERT_INTO (co) SELECT ...

Note that [projections](#projection) of specified [`SQLQuery`](#sql) must match the columns of the
[`Relation`](#relation).

#### Update & Delete  {#update-delete}

SQL databases support `UPDATE` and `DELETE` statements for bulk operations. Circumflex ORM provides
equivalent abstractions for these operations, `Update` and `Delete` respectively.

The `Update` query allows you to use DSL for updating fields of multiple records at a time:

    lang:scala
    val co = Country AS "co"
    UPDATE (co) SET (co.name, "United Kingdom") SET (co.code, "uk")

The `Delete` query allows you to delete multiple records from a single [relation](#relation):

    lang:scala
    val co = Country AS "co"
    DELETE (co)

An optional `WHERE` clause specifies [predicate](#predicate) for searched update or delete:

    lang:scala
    UPDATE (co) SET (co.name, "United Kingdom") WHERE (co.code LIKE 'uk')
    DELETE (co) WHERE (co.code LIKE 'uk')

Many database vendors also allow `USING` clause in `UPDATE` and `DELETE` statements.
Circumflex ORM does not support this feature yet.

## Advanced concepts   {#advanced}

### Transactions & Demarcation Patterns  {#transaction}

### Transaction-Scoped Cache   {#cache}

### Auxiliary Database Objects   {#aux}

### Dialects   {#dialect}

### Alias Resolution   {#alias}

### Native Queries   {#native}

### Configuration Parameters   {#cfg}


   [orm-wiki]:          http://en.wikipedia.org/wiki/Object-relational_mapping
                        "ORM definition on Wikipedia"
   [crud-wiki]:         http://en.wikipedia.org/wiki/Create,_read,_update_and_delete
                        "CRUD definition on Wikipedia"
   [joins-wiki]:        http://en.wikipedia.org/wiki/Join_(SQL)
                        "SQL Join definition on Wikipedia"
   [rel-algebra-wiki]:  http://en.wikipedia.org/wiki/Relational_algebra
                        "Relational algebra definition on Wikipedia"
   [n+1]:               http://www.pramatr.com/blog/2009/02/05/sql-n-1-selects-explained/
                        "n+1 selects explained"
