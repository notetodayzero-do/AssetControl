using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using AssetControl.Entity;
using AssetControl.Models;
namespace AssetControl.Controllers
{
    public class UserController : Controller
    {
        Entity.EXT26_ASSETCONTROLEntities db_user = new Entity.EXT26_ASSETCONTROLEntities(); 
        Entity.EXT_APIEntities db_api = new Entity.EXT_APIEntities();
        // GET: User
        public ActionResult Index()
        {
           List<ext26_assetcontrol_user> User = db_user.ext26_assetcontrol_user.ToList();
            return View();
        }
    }
}