using AssetControl.Entity;
using AssetControl.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.ModelBinding;
using System.Web.Mvc;

namespace AssetControl.Controllers
{
    public class ComputerSpecController : BaseController
    {
        Entity.EXT26_ASSETCONTROLEntities db = new Entity.EXT26_ASSETCONTROLEntities();
        // GET: Computer_Spec
        public ActionResult Index()
        {
            List<ext26_assetcontrol_computer_spec> computer_spec = db.ext26_assetcontrol_computer_spec.ToList();
            return View(computer_spec);
        }

        [HttpGet]
        public ActionResult Create()
        {
            try
            {
                List<ext26_assetcontrol_type_computer> typecoms = db.ext26_assetcontrol_type_computer.ToList();
                ViewBag.typecoms = typecoms;

                ext26_assetcontrol_computer_spec model = new ext26_assetcontrol_computer_spec();
                model.create_date = DateTime.Now;


                return View(model);
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
            }
            return RedirectToAction("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(ext26_assetcontrol_computer_spec spce)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    spce.create_date = DateTime.Now;

                    // set current logged-in user as creator ---
                    var current = GetUser();
                    if (current != null)
                    {
                        spce.create_by = current.UserName ?? current.EmpID;
                    }

                    db.ext26_assetcontrol_computer_spec.Add(spce);
                    db.SaveChanges();

                    TempData["Success"] = "Create spec successful";
                    return RedirectToAction("Index");

                }

                // If validation failed, show the form again with validation messages
                TempData["Error"] = "Validation failed. Please check the input values.";
                return View(spce);
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
                return View(spce);
            }
        }

        // GET: Edit spec
        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest);
            }
            var spec = db.ext26_assetcontrol_computer_spec.Find(id);
            if (spec == null)
            {
                return HttpNotFound();
            }
            return View(spec);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(ext26_assetcontrol_computer_spec spec)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    var current = GetUser();
                    if (current != null)
                    {
                        spec.update_by = current.UserName ?? current.EmpID;
                        spec.update_date = DateTime.Now;
                    }

                    db.Entry(spec).State = System.Data.Entity.EntityState.Modified;
                    db.SaveChanges();
                    TempData["Success"] = "แก้ไข Spec เรียบร้อยแล้ว";
                    return RedirectToAction("Index");
                }
                TempData["Error"] = "Validation failed. Please check the input values.";
                return View(spec);
            }
            catch (Exception ex)
            {
                TempData["Error"] = ex.Message;
                return View(spec);
            }
        }

    }
}