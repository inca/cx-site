package ru.circumflex
package site

import core._, web._, freemarker._
import java.io._
import org.apache.commons.io.FileUtils._

class MainRouter extends RequestRouter {

  'sitemap := new Page("/pages/sitemap")

  get("/api/?") = redirect("/api/" + cx("cx.version") +  "/index.html")
  get("/api/:version/?") = redirect("/api/" + param("version") + "/index.html")
  get("/api/:version/*.html") = {
    val version = param("version")
    val file = new File("src/main/webapp/api/" + version + "/" + uri(2) + ".html")
    if (file.isFile) {
      'content := readFileToString(file, "UTF-8")
      ftl("/layout.ftl")
    } else sendError(404)
  }
  get("/api/:version/:project/:file.scala") = redirect(
    "/api/" + param("version") + "/" + param("project") + "/src/main/scala/" +
        param("file") + ".scala.html")

  get("/.me") = ftl("/me.ftl")
  post("/.me") = markeven.toHtml(param("me"))

  get("/") = forward("/index.html")
  get("/*.html") = {
    val page = new Page("/pages/" + uri(1))
    if (!page.exists) error(404)
    'page := page.toHtml
    ftl("/page.ftl")
  }

  // None matched, let's try to guess a page
  get("+/") = redirect(uri(1) + "/index.html")
  get("+") = redirect(uri(1) + ".html")

}
