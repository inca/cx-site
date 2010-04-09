package ru.circumflex

import _root_.ru.ciridiri.{Main => Ciridiri}
import _root_.ru.circumflex.core.RequestRouter
import _root_.ru.circumflex.freemarker.FreemarkerHelper
import _root_.java.text.SimpleDateFormat
import _root_.java.util.Date
import _root_.org.slf4j.LoggerFactory

class Main extends RequestRouter
    with FreemarkerHelper {
  val log = LoggerFactory.getLogger("ru.circumflex")
  new Ciridiri()
}