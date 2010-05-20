package ru.circumflex.site

import ru.circumflex.core._
import ru.circumflex.freemarker.FreemarkerHelper
import ru.ciridiri.{Page, CiriDiri}
import ru.circumflex.md.Markdown
import java.text.SimpleDateFormat
import java.util.Date

class MainRouter extends RequestRouter
    with FreemarkerHelper {

  'host := header.getOrElse("Host", "")
  'currentYear := new SimpleDateFormat("yyyy").format(new Date)
  'sitemap := Page.findByUri("/sitemap")    // read sitemap

  new CiriDiri {    // let ciridiri handle the rest
    override def onFound(page: Page) = {
      println("Preved " + page)
    }
  }

  // Markdown Live
  get("/.mdwn") = ftl("/mdwn.ftl")
  post("/.mdwn") = Markdown(param('md))
  get("/.md-cheatsheet") =
      if (isXhr)
        Page.findByUriOrEmpty("/.md-cheatsheet").toHtml()
      else rewrite("/.md-cheatsheet.html")

}
