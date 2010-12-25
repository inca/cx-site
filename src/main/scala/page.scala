package ru.circumflex
package site

import java.util.regex.Pattern
import java.io.File
import org.apache.commons.io.FileUtils._
import java.lang.StringBuilder
import xml._, web._, freemarker._

object Page {
  def fromXML(e: Elem) = new Page((e \ "@path").text, e.text)
}

class Page(val path: String, val title: String = "") {
  val fullpath = servletContext.getRealPath(path + ".me")
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
  lazy val toc = new TOC(content)
}

object TOC {
  val rNoToc = Pattern.compile("^<!--#notoc-->$", Pattern.MULTILINE)
  val rHeadings = "<h(\\d)\\s*(id\\s*=\\s*(\"|')(.*?)\\3)?\\s*>(.*?)</h\\1>".r
}

class TOC(val html: String) {
  case class Heading(level: Int, id: String, body: String) {
    def toHtml: String =
      if (id == null) "<span>" + body + "</span>"
      else "<a href=\"#" + id + "\">" + body + "</a>"
    override def toString = toHtml
  }
  val disabled = TOC.rNoToc.matcher(html).find()
  val headings: Seq[Heading] = TOC.rHeadings.findAllIn(html)
      .matchData
      .map(m => new Heading(m.group(1).toInt, m.group(4), m.group(5)))
      .toList
  val toHtml: String = if (headings.size == 0 || disabled) "" else {
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