using AssetControl.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AssetControl.Controllers
{
    /// <summary>
    /// BaseController เป็น Controller หลักที่ Controller ทุกตัวในระบบสืบทอด (inherit) มา
    /// เพื่อรวม logic กลางที่ใช้ร่วมกัน เช่น การตรวจสอบ Session และการเข้าถึงฐานข้อมูล
    /// </summary>
    public class BaseController : Controller
    {
        // db     : เชื่อมต่อฐานข้อมูลหลักของระบบ AssetControl
        protected readonly Entity.EXT26_ASSETCONTROLEntities db = new Entity.EXT26_ASSETCONTROLEntities();

        // db_api : เชื่อมต่อฐานข้อมูล API (ข้อมูลผู้ใช้งาน / พนักงาน)
        protected readonly Entity.EXT_APIEntities db_api = new Entity.EXT_APIEntities();


        /// <summary>
        /// ดึงข้อมูล User ที่ล็อกอินอยู่จาก Session
        /// </summary>
        /// <returns>Entity.User ถ้ามี Session, null ถ้ายังไม่ได้ล็อกอิน</returns>
        protected Entity.User GetUser()
        {
            var user = Session["USER"] as Entity.User;
            if (user != null)
            {
                return user;
            }

            return null;
        }


        /// <summary>
        /// ทำงานก่อนทุก Action ใน Controller ที่ inherit BaseController
        /// ใช้ตรวจสอบว่าผู้ใช้ล็อกอินแล้วหรือยัง
        /// ถ้ายังไม่ได้ล็อกอิน (Session["USER"] == null) จะ redirect ไปหน้า Login ทันที
        /// </summary>
        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var user = Session["USER"] as Entity.User;

            // ถ้าไม่มี Session ของผู้ใช้ → redirect ไปหน้า Login
            if (user == null)
            {
                filterContext.Result = new RedirectResult(Url.Action("index", "login"));
                return;
            }

            base.OnActionExecuting(filterContext);
        }
    }
}