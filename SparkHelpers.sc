//interp.repositories() ++= Seq(coursier.maven.MavenRepository("https://jitpack.io"))
import $ivy.`org.apache.spark::spark-sql:2.4.3` // Or use any other 2.x version here
import $ivy.`sh.almond:scala-kernel-api_2.12.8:0.5.0`

import org.apache.spark.sql._

implicit class RichDF(val df: DataFrame)(implicit kernel: almond.api.JupyterApi) {
  def showHTML(limit:Int = 20): Unit = {
    import xml.Utility.escape
    val data = df.take(limit)
    val header = df.schema.fieldNames.toSeq
    val rows: Seq[Seq[String]] = data.map { row =>
      row.toSeq.map { cell =>
        cell match {
          case null => "null"
          case binary: Array[Byte] => binary.map("%02X".format(_)).mkString("[", " ", "]")
          case array: Array[_] => array.mkString("[", ", ", "]")
          case seq: Seq[_] => seq.mkString("[", ", ", "]")
          case _ => cell.toString
        }
      }: Seq[String]
    }

    kernel.publish.html(s"""
    <div>
      <table border="1" class="dataframe">
      <thead>
        <tr>
        ${header.map(h => s"<th>${escape(h)}</th>").mkString}
        </tr>
      </thead>
      <tbody>
      ${rows.map { row =>
        s"<tr>${row.map { c => s"<td>${escape(c)}</td>" }.mkString}</tr>"
      }.mkString
      }
        </tbody>
      </table>
    </div>""")
  }
}
