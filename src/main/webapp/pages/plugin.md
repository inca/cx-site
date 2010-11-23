# Circumflex Maven Plugin

Circumflex comes shipped with handy Maven plugin which can help you with following tasks:

  * [configuring Circumflex application](#cfg) using `pom.xml` instead of `cx.properties`;
  * [exporting database schema](#schema) of [Circumflex ORM](/orm.html) project on build;
  * generating source code documentation with [Docco](/index.html#docco).

# Configuring Circumflex Application    {#cfg}

The `cfg` goal is used to create `cx.properties` file filled with properties defined in
the `properties` section of your `pom.xml`. It is a very convenient way to configure
various aspects of your Circumflex application. This approach gives you following
advantages:

  * different environments using Maven profiles and `settings.xml`;
  * property inheritance;
  * possibility to reuse properties with the `${prop}` notation inside your `pom.xml`;

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
your `pom.xml` (note that `cx.properties` from your `src/main/resourses`
**will not be used anymore**):

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

# Exporting Database Schema   {#schema}

# Generating Source Documentation   {#docco}

