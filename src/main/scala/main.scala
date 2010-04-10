package ru.circumflex.site

import _root_.ru.circumflex.freemarker.FreemarkerHelper
import _root_.ru.ciridiri.CiriDiri
import java.text.SimpleDateFormat
import java.util.Date
import ru.circumflex.core.{Circumflex, RequestRouter}

class MainRouter extends RequestRouter
    with FreemarkerHelper {
  ctx += "host" -> header("Host")
  ctx += "currentYear" -> new SimpleDateFormat("yyyy").format(new Date)
  new CiriDiri()
}