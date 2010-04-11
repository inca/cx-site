package ru.circumflex.site

import _root_.ru.circumflex.freemarker.FreemarkerHelper
import java.text.SimpleDateFormat
import java.util.Date
import ru.circumflex.core.{Circumflex, RequestRouter}
import ru.ciridiri.{Page, CiriDiri}

class MainRouter extends RequestRouter
    with FreemarkerHelper {
  ctx += "host" -> header("Host")
  ctx += "currentYear" -> new SimpleDateFormat("yyyy").format(new Date)
  // read sitemap
  ctx += "sitemap" -> Page.findByUri("/sitemap")
  // let ciridiri handle the rest
  new CiriDiri()
}