using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using AssetControl.Entity;
using AssetControl.Models;


namespace AssetControl.Controllers
{
    public class LoginController : Controller
    {
        Entity.EXT_APIEntities db_api = new Entity.EXT_APIEntities();
        // GET: Login
        public ActionResult Index()
        {
            var users = Session["USER"];
            if (users != null)
            {
                return RedirectToAction("Index", "Home");
            }

            Entity.User user = new Entity.User();
            return View(user);
        }

        

        [HttpPost]
        public ActionResult login(User login)
        {
            
            try
            {
                var user = db_api.Users.FirstOrDefault(m => m.UserName == login.UserName && m.Password == login.Password);
                if(user != null)
                {
                    Session["USER"] = user;
                    return RedirectToAction("Index", "Home");
                }
                else
                {
                    TempData["Fail"] = "รหัสผ่านไม่ถูกต้อง";
                }

            }
            catch (Exception ex)
            {
                var message = ex.InnerException?.Message ?? ex.Message;
                TempData["Error"] = "เกิดข้อผิดพลาด: " + message;
                return RedirectToAction("index");

            }
            return RedirectToAction("Index");
        }

        [HttpPost]
        public ActionResult qrcode(string empId)
        {

            var users = db_api.Users.FirstOrDefault(m => m.EmpID == empId);

            Session["USER"] = users;
            return RedirectToAction("Index","Home");
        }

    }
}