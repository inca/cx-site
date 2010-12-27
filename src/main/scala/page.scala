package ru.circumflex
package site

import org.apache.commons.io.FileUtils._
import net.sf.ehcache._
import xml._, web._, freemarker._, core._
import java.io.{Serializable, File}

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
  lazy val sourceContent = readFileToString(src, "UTF-8")
  lazy val toHtml = markeven.toHtml(sourceContent)
  def exists = src.isFile
  def expired = src.lastModified > createdAt
}

class Docs(val id: String) extends Cacheable {
  val basePath = "/docs/" + id
  val descriptorFile = new File(basePath + "/index.xml")
  val descriptor = XML.loadFile(descriptorFile)
  val title = (descriptor \ "title").text
  val pages: Seq[Page] = (descriptor \ "pages" \ "page").flatMap {
    case e: Elem =>
      val name = (e \ "@name").text
      val title = (e \ "@title").text
      Some(new Page(basePath + "/" + name, title))
    case _ => None
  }
  def expired = descriptorFile.lastModified > createdAt || pages.exists(_.expired)

  lazy val renderIndex: String = "INDEX OF " + id
  lazy val renderAssembly: String = "ASSEMBLY OF " + id
  def renderPage(page: String): String = "PAGE " + page
}