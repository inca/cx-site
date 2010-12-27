package ru.circumflex
package site

import core._, web._, freemarker._
import java.io._
import org.apache.commons.io.FileUtils._

class MainRouter extends RequestRouter {

  'sitemap := Cache.get[Page]("page:/pages/sitemap", new Page("/pages/sitemap"))

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

  protected def fetchDocs: Docs = try {
    Cache.get[Docs]("docs:" + param("id"), new Docs(param("id")))
  } catch {
    case _ =>
      sendError(404)
  }

  get("/docs/:id/index.html") = {
    'docs := fetchDocs
    ftl("/docs-index.ftl")
  }
  get("/docs/:id/assembly.html") = {
    'docs := fetchDocs
    ftl("/docs-assembly.ftl")
  }
  get("/docs/:id/:page.html") = {
    val docs = fetchDocs
    docs.getPage(param("page")) match {
      case Some(page) =>
        'docs := docs
        'page := page
        'prevPage := docs.getPreviousPage(page)
        'nextPage := docs.getNextPage(page)
        ftl("/docs-page.ftl")
      case _ => sendError(404)
    }
  }

  post("/.me") = {
    var text = param("text")
    if (text.length > 2048)
      text = text.substring(0, 2048)
    markeven.toHtml(text)
  }

  get("/") = forward("/index.html")
  get("/*.html") = {
    val path = "/pages/" + uri(1)
    val page = Cache.get("page:" + path, new Page(path))
    if (!page.exists) error(404)
    'page := page.toHtml
    ftl("/page.ftl")
  }

  // None matched, let's try to guess a page
  get("+/") = redirect(uri(1) + "/index.html")
  get("+") = redirect(uri(1) + ".html")

}
