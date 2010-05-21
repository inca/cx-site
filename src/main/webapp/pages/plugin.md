Circumflex Maven Plugin
=======================

Circumflex comes shipped with handy Maven plugin that can help you with following tasks:

  * [provide Circumflex configuration parameters](#cfg) in `pom.xml` instead of `cx.properties`;
  * [create database schema](#schema) on build;
  * generate source code documentation with [Docco](/index.html#docco).

## Configuration     {#cfg}

The `cfg` goal is used to create `cx.properties` file filled with properties defined in
the `properties` section of your `pom.xml`. It is a very convenient way to configure Circumflex:

  * you can setup different environments using Maven profiles;
  * you can reuse properties with the `${prop}` notation inside your `pom.xml`;
  * you gain the advantages of property inheritance;
  * you can override properties with your `settings.xml` file to create custom environment
  on specific machine.

All you have to do is configure the `cfg` goal of `maven-cx-plugin`:

    lang:xml
    <?xml version="1.0" encoding="UTF-8"?>
    <project xmlns="http://maven.apache.org/POM/4.0.0"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                                 http://maven.apache.org/maven-v4_0_0.xsd">
      <build>
        <sourceDirectory>src/main/scala</sourceDirectory>
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

After that you may specify configuration properties right in the `properties` section of
your `pom.xml`:

    lang:xml
    <project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/maven-v4_0_0.xsd">
      <properties>
         <cx.router>com.myapp.web.MainRouter</cx.router>
         <cx.public>/static</cx.public>
      </properties>
    </project>

Of course, nothing stops you from using Circumflex to deal with your own configuration:

    lang:scala
    Circumflex("myCfgParam") match {
      case s: String => ...
      case _ => ...
    }

## Database Schema   {#schema}

Coming soon...