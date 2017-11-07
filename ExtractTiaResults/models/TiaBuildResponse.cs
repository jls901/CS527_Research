using System;
using System.Collections;
using System.Collections.Generic;


namespace ExtractTiaResults.Models
{
    public class TiaBuildResponse
    {
        public int count { get; set; }
        public List<Build> value { get; set; }
    }
}