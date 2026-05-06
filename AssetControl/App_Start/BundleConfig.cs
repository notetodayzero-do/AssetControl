using System.Web;
using System.Web.Optimization;

namespace AssetControl
{
    public class BundleConfig
    {
        // For more information on bundling, visit https://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js"));

            bundles.Add(new Bundle("~/bundles/bootstrap").Include(
                     "~/Scripts/wowdash/js/lib/audioplayer.js",
                     "~/Scripts/wowdash/js/lib/bootstrap.bundle.min.js",
                     "~/Scripts/wowdash/js/lib/file-upload.js",
                     "~/Scripts/wowdash/js/lib/iconify-icon.min.js",
                     "~/Scripts/wowdash/js/lib/jquery-ui.min.js",
                     "~/Scripts/wowdash/js/lib/dataTables.min.js",
                     "~/Scripts/wowdash/js/lib/magnifc-popup.min.js",
                     "~/Scripts/wowdash/js/lib/prism.js",
                     "~/Scripts/wowdash/js/lib/slick.min.js",
                     "~/Scripts/wowdash/js/app.js",
                     "~/Scripts/wowdash/js/editor.highlighted.min.js",
                     "~/Scripts/wowdash/js/editor.katex.min.js",
                     "~/Scripts/wowdash/js/editor.quill.js",
                     "~/Scripts/wowdash/js/flatpickr.js",
                     "~/Scripts/wowdash/js/lib/dataTables.buttons.min.js",
                     "~/Scripts/wowdash/js/lib/buttons.html5.min.js",
                     "~/Scripts/wowdash/js/invoice.js"
                     ));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                      "~/Content/wowdash/css/lib/apexcharts.css",
                      "~/Content/wowdash/css/lib/audioplayer.css",
                      "~/Content/wowdash/css/lib/bootstrap.min.css",
                      "~/Content/wowdash/css/lib/editor-katex.min.css",
                      "~/Content/wowdash/css/lib/dataTables.min.css",
                      "~/Content/wowdash/css/lib/editor.atom-one-dark.min.css",
                      "~/Content/wowdash/css/lib/editor.quill.snow.css",
                      "~/Content/wowdash/css/lib/file-upload.css",
                      "~/Content/wowdash/css/lib/flatpickr.min.css",
                      "~/Content/wowdash/css/lib/full-calendar.css",
                      "~/Content/wowdash/css/lib/jquery-jvectormap-2.0.5.css",
                      "~/Content/wowdash/css/lib/magnific-popup.css",
                      "~/Content/wowdash/css/lib/prism.css",
                      "~/Content/wowdash/css/style.css",
                      "~/Content/wowdash/css/remixicon.css",
                      "~/Content/wowdash/css/lib/buttons.dataTables.css",
                      "~/Content/wowdash/css/lib/slick.css"));
        }
    }
}
