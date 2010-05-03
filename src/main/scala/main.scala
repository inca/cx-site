package ru.circumflex.site

import ru.circumflex.core._
import ru.circumflex.freemarker.FreemarkerHelper
import ru.ciridiri.{Page, CiriDiri}
import ru.circumflex.md.Markdown

import java.text.SimpleDateFormat
import java.util.Date
import org.apache.commons.io.IOUtils

class MainRouter extends RequestRouter
    with FreemarkerHelper {

  'host := header("Host")
  'currentYear := new SimpleDateFormat("yyyy").format(new Date)
  'sitemap := Page.findByUri("/sitemap") // read sitemap

  new CiriDiri // let ciridiri handle the rest
  
  // now some rough stuff for Git
  get("/.git") = {
    val p = Runtime.getRuntime.exec(Array("git","status"))
    val in = p.getInputStream
    try {
      var status = new String(IOUtils.toCharArray(in))
          .replaceAll("(?:\\n|\\A)#", "\n")
          .replaceAll("\n(?! {4,})", "  \n")
      'status := Markdown(status)
    } finally {
      in.close
      p.waitFor
    }
    ftl("/git.ftl")
  }

  post("/.git") = {
    if (param('add).isDefined) {
      Runtime.getRuntime.exec(Array("git","add",".")).waitFor
    } else if (param('commit).isDefined) {
      val msg = param('message).get
      val p = Runtime.getRuntime.exec(Array("git","commit","-a","-m",msg))
      val out = p.getOutputStream
      try {
        out.write(msg.getBytes("utf-8"))
      } finally {
        out.close
      }
      p.waitFor
    } else if (param('push).isDefined) {
      Runtime.getRuntime.exec(Array("git","push","origin","master")).waitFor
    } else if (param('pull).isDefined) {
      Runtime.getRuntime.exec(Array("git","pull","origin","master")).waitFor
    }
    redirect("/.git")
  }

}
