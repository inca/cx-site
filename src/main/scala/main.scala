package ru.circumflex.site

import _root_.freemarker.cache._
import _root_.freemarker.template.{TemplateExceptionHandler, Configuration}
import ru.circumflex._, core._, web._, freemarker._
import java.text.SimpleDateFormat
import java.util.Date
import java.io.File
import org.apache.commons.io.FileUtils._
import java.lang.{String, StringBuilder}

class Page(val path: String) {
  val fullpath = servletContext.getRealPath("/pages/" + path + ".me")
  val src = new File(fullpath)
  val cache = new File(fullpath + ".html")
  def exists = src.isFile
  protected lazy val content = if (cache.isFile && cache.lastModified > src.lastModified) {
    readFileToString(cache, "UTF-8")
  } else {
    val html = markeven.toHtml(readFileToString(src, "UTF-8"))
    writeStringToFile(cache, html, "UTF-8")
    html
  }
  def toHtml = content
}

class MainRouter extends RequestRouter {

  'sitemap := new Page("sitemap")

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
    val page = new Page(uri(1))
    if (!page.exists) error(404)
    'page := page.toHtml
    'toc := new TOC(page.toHtml)
    ftl("/page.ftl")
  }

  // None matched, let's try to guess a page
  get("+/") = redirect(uri(1) + "/index.html")
  get("+") = redirect(uri(1) + ".html")

}

object TOC {
  val rHeadings = "<h(\\d)\\s*(id\\s*=\\s*(\"|')(.*?)\\3)?\\s*>(.*?)</h\\1>".r
}

class TOC(val html: String) {
  case class Heading(level: Int, id: String, body: String) {
    def toHtml: String =
      if (id == null) "<span>" + body + "</span>"
      else "<a href=\"#" + id + "\">" + body + "</a>"
    override def toString = toHtml
  }
  val headings: Seq[Heading] = TOC.rHeadings.findAllIn(html)
      .matchData
      .map(m => new Heading(m.group(1).toInt, m.group(4), m.group(5)))
      .toList
  val toHtml: String = if (headings.size == 0) "" else {
    val sb = new StringBuilder
    def startList(l: Int) = sb.append("  " * l + "<li><ul>\n")
    def endList(l: Int) = sb.append("  " * (l - 1) + "</ul></li>\n")
    def add(l: Int, h: Heading) = sb.append("  " * l + "<li>" + h.toString + "</li>\n")
    def formList(level: Int, index: Int): Unit = if (index < 0 || index >= headings.size) {
      if (level > 1) {
        endList(level)
        formList(level - 1, index)
      }
    } else {
      val h = headings(index)
      if (level < h.level) {
        startList(level)
        formList(level + 1, index)
      } else if (level > h.level) {
        endList(level)
        formList(level - 1, index)
      } else {
        add(level, h)
        formList(level, index + 1)
      }
    }
    formList(1, 0)
    "<ul>\n" + sb.toString + "</ul>"
  }
}

class FreeMarkerConf extends Configuration {
  setObjectWrapper(new ScalaObjectWrapper())
  setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER)
  setDefaultEncoding("utf-8")
  setTemplateLoader(new FileTemplateLoader(new File("src/main/resources"), false))
  setSharedVariable("currentYear", new SimpleDateFormat("yyyy").format(new Date))
}
