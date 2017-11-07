using System;
using System.Collections;
using System.Collections.Generic;


namespace ExtractTiaResults.Models
{
    public class TiaTestRunResponse
    {
        public int count { get; set; }
        public List<TestRun> value { get; set; }
    }
}