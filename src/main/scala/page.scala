package ru.circumflex
package site

import org.apache.commons.io.FileUtils._
import net.sf.ehcache._
import xml._, web._, freemarker._, core._
import ru.circumflex.{markeven => me}
import java.io.{Serializable, File}
import java.util.UUID
import java.util.regex.Pattern

object Cache {
  protected val _cacheManager = new CacheManager()
  protected val _cache = _cacheManager.addCacheIfAbsent("cx-site")

  def get[T <: Cacheable](key: String, default: => T): T = {
    val elem = _cache.get(key)
    if (elem == null) {
      val d = default
      store(key, d)
      return d
    } else {
      var v = elem.getValue.asInstanceOf[T]
      if (v.expired) {
        v = default
        store(key, v)
      }
      return v
    }
  }

  def store(key: String, value: AnyRef): Element = {
    val e = new Element(key, value)
    _cache.put(e)
    return e
  }
}

trait Cacheable extends Serializable {
  val createdAt = System.currentTimeMillis
  def expired: Boolean
}

class Page(val path: String, val title: String = "") extends Cacheable {
  val fullpath = servletContext.getRealPath(path + ".me")
  val src = new File(fullpath)
  val anchor = "section_" + path.replaceAll(".*/", "").replaceAll("[ _-]", "_")
  lazy val sourceContent = readFileToString(src, "UTF-8")

  lazy val toHtml = me.processor
      .addMacro("link", cnt => cnt)
      .toHtml(sourceContent)

  lazy val toAssemblyHtml = me.processor
      .addMacro("link", cnt => {
    val m = Pattern.compile("(.*)\\.html(#.*)?").matcher(cnt)
    if (m.matches) {
      val anchor = m.group(2)
      if (anchor != null) anchor
      else {
        // lookup page
        val path = m.group(1)
        val page = Cache.get[Page]("page:" + path, new Page(path))
        if (page.exists) page.anchor
        else "#"
      }
    } else "#"
  }).toHtml(sourceContent)

  def exists = src.isFile
  def expired = src.lastModified > createdAt
  override def equals(o: Any) = o match {
    case p: Page => p.path == this.path
    case _ => false
  }
  override def hashCode = this.path.hashCode
}

class Docs(val id: String) extends Cacheable {
  val basePath = servletContext.getRealPath("/docs/" + id)
  val descriptorFile = new File(basePath + "/index.xml")
  val descriptor = XML.loadFile(descriptorFile)
  val title = (descriptor \ "title").text.replaceAll("&", "<span class=\"amp\">&amp;</span>")
  val pages: Seq[Page] = (descriptor \ "pages" \ "page").flatMap {
    case e: Elem =>
      val name = (e \ "@name").text
      val title = (e \ "@title").text
      val path = "/docs/" + id + "/" + name
      Some(Cache.get[Page]("page:" + path, new Page(path, title)))
    case _ => None
  }
  def expired = descriptorFile.lastModified > createdAt || pages.exists(_.expired)
  def getPage(page: String): Option[Page] = {
    val path = "/docs/" + id + "/" + page
    pages.find(p => p.path == path)
  }
  def getNextPage(page: Page): Option[Page] = {
    val i = pages.findIndexOf(p => p == page)
    if (i == -1 || i >= pages.length - 1) None
    else Some(pages(i + 1))
  }
  def getPreviousPage(page: Page): Option[Page] = {
    val i = pages.findIndexOf(p => p == page)
    if (i <= 0) None
    else Some(pages(i - 1))
  }
}