using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AssetControl.Models
{
    public class USER_CUSTOM
    {
        public int UID { get; set; }
        public string UserName { get; set; }
        public string Password { get; set; }
        public string FName { get; set; }
        public string LName { get; set; }
        public string Type { get; set; }
        public string Email { get; set; }
        public string EmpID { get; set; }
        public string Factory { get; set; }
        public Nullable<int> IsDisable { get; set; }
    }
}