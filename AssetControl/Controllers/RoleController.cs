using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using AssetControl.Models;
using System.Net;
using System.Data.Entity;
using AssetControl.Entity;

namespace AssetControl.Controllers
{
    public class RoleController : Controller
    {
        // หน้าแสดงรายการ Role
        Entity.EXT26_ASSETCONTROLEntities db = new Entity.EXT26_ASSETCONTROLEntities();
        public ActionResult Index()
        {
            var roles = db.ext26_assetcontrol_role.ToList();
            return View(roles);
        }

        public ActionResult Create()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(ext26_assetcontrol_role role)
        {
            if (ModelState.IsValid)
            {
                // ตรวจสอบชื่อ Role ซ้ำ
                var exists = db.ext26_assetcontrol_role.Any(r => r.role_name == role.role_name);
                if (exists)
                {
                    ModelState.AddModelError("role_name", "ชื่อสิทธิ์ถูกใช้งานแล้ว");
                    TempData["Error"] = "ชื่อสิทธิ์ถูกใช้งานแล้ว";
                    return View(role);
                }

                // เพิ่ม Role ใหม่
                db.ext26_assetcontrol_role.Add(role);
                db.SaveChanges();
                TempData["Success"] = "สร้างสิทธิ์เรียบร้อยแล้ว";
                return RedirectToAction("Index");
            }
            return View(role);
        }

        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            var role = db.ext26_assetcontrol_role.Find(id);
            if (role == null)
            {
                return HttpNotFound();
            }
            return View(role);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(ext26_assetcontrol_role role)
        {
            if (ModelState.IsValid)
            {
                // ตรวจสอบชื่อ Role ซ้ำสำหรับรายการอื่น
                var exists = db.ext26_assetcontrol_role.Any(r => r.role_name == role.role_name && r.id_role != role.id_role);
                if (exists)
                {
                    ModelState.AddModelError("role_name", "ชื่อสิทธิ์ถูกใช้งานแล้ว");
                    TempData["Error"] = "ชื่อสิทธิ์ถูกใช้งานแล้ว";
                    return View(role);
                }

                // บันทึกการแก้ไข
                db.Entry(role).State = EntityState.Modified;
                db.SaveChanges();
                TempData["Success"] = "แก้ไขสิทธิ์เรียบร้อยแล้ว";
                return RedirectToAction("Index");
            }
            return View(role);
        }

        public ActionResult Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            var role = db.ext26_assetcontrol_role.Find(id);
            if (role == null)
            {
                return HttpNotFound();
            }
            return View(role);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            var role = db.ext26_assetcontrol_role.Find(id);
            if (role != null)
            {
                // ลบ Role
                db.ext26_assetcontrol_role.Remove(role);
                db.SaveChanges();
                TempData["Success"] = "ลบสิทธิ์เรียบร้อยแล้ว";
            }
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }


    }
}