using AssetControl.Entity;
using AssetControl.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AssetControl.Controllers
{
    public class TranferController : Controller
    {
        Entity.EXT26_ASSETCONTROLEntities db = new Entity.EXT26_ASSETCONTROLEntities();
        Entity.EXTEDIEntities dbedi = new Entity.EXTEDIEntities();
        Entity.EXT_APIEntities dbapi = new Entity.EXT_APIEntities();
        // GET: Tranfer
        public ActionResult Index(int? Id)
        {
            try
            {
                if (!Id.HasValue)
                {
                    return RedirectToAction("Index", "Asset");
                }

                var assets = db.ext26_assetcontrol_asset.FirstOrDefault(a => a.id_asset == Id.Value);
                if (assets == null)
                {
                    TempData["Error"] = "Asset not found.";
                    return RedirectToAction("Index", "Asset");
                }

                var spec = db.ext26_assetcontrol_computer_spec
                    .FirstOrDefault(s => s.id_com_spec == assets.id_com_spec);

                var comTran = new ext26_assetcontrol_computer_tran
                {
                    id_asset    = assets.id_asset,
                    create_date = DateTime.Now,
                };

                List<USER_CUSTOM> Users = dbapi.Users.Select(u => new USER_CUSTOM
                {
                    UID   = u.UID,
                    EmpID = u.EmpID,
                    FName = u.FName,
                    LName = u.LName
                }).ToList();

                List<DEPT> Depts = dbedi.DEPTs.ToList();

                ViewBag.assets = assets;
                ViewBag.spec   = spec;
                ViewBag.Users  = Users;
                ViewBag.Depts  = Depts;
                return View(comTran);

             
                
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
               
            }
            return View();
        }
    }
}