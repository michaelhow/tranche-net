﻿using System;

namespace AbstractSyntaxTree
{
    public class Invoke : Expression
    {
        public Expression Object { get; set; }
        public String Method { get; set; }
        public ExpressionList Actuals { get; set; }
        public SpecialFunction SpecialFunc { get; set; }
        //public Descriptor Descriptor { get; set; }

        public Invoke (string method, ExpressionList actuals)
        {
            Method = method;
            Actuals = actuals;
        }
        public Invoke(Expression obj, String method, ExpressionList actuals)
        {
            Object = obj;
            Method = method;
            Actuals = actuals;
        }
        public Invoke(Expression obj, SpecialFunction func)
        {
            Object = obj;
            SpecialFunc = func;
        }

        public override String Print(int depth)
        {
            return (Object == null ? "global" : Object.Print(depth)) 
                + "." + (string.IsNullOrEmpty(Method) ? SpecialFunc.Print(depth) : Method) 
                + (Actuals == null ? string.Empty : "(" + Actuals.Print(depth) + ")");
        }

        public override void Visit (Visitor v)
        {
            v.VisitInvoke(this);
        }
    }
}