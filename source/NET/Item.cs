using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace IComparable
{
    public class Item : IComparable<Item>
    {
        private string _folder;
        private string _serverItem;

        public Item(string folder, string serverItem)
        {
            Folder = folder;
            ServerItem = serverItem;
            
        }

        public string Folder
        {
            get { return _folder; }
            set { _folder = value; }
        }

        public string ServerItem
        {
            get { return _serverItem; }
            set { _serverItem = value; }
        }

        #region IComparable<Item> Members

        // Remember ToLower in implementation
        public int CompareTo(Item other)
        {
            if (this._folder.ToLower().CompareTo(other.Folder.ToLower()) == 0)
            {
                return this.ServerItem.ToLower().CompareTo(other.ServerItem.ToLower());
            }

            return this._folder.CompareTo(other.Folder);
        }

        #endregion
    }
}
