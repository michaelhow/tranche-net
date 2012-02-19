﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

using LexicalAnalysis;
using SemanticAnalysis;
using SyntaxAnalysis;
using ILGen;

namespace tc
{
    class Program
    {
        static void Main (string[] args)
        {
            if (args.Length < 1)
            {
                ShowUsage();
                return;
            }
            Compile(args);
        }

        private static void Compile (IList<string> args)
        {
            //combine multiple source files
            var source = new StringBuilder();

            foreach (var file in args)
                source.Append(File.ReadAllText(file));

            var scan = new Scanner();
            scan.SetSource(source.ToString(), 0);

            var parser = new Parser(scan);
            if (!parser.Parse())
            {
                Console.WriteLine("Parsing failed!");
                return;
            }

            var root = parser.SyntaxTreeRoot;
            Console.WriteLine(root.Print(0));

            var mgr = new ScopeManager();

            var first = new FirstPass(root, mgr);
            var second = new SecondPass(root, mgr);
            first.Run();
            second.Run();

            var asmName = args[0].Substring(args[0].LastIndexOf("\\", StringComparison.Ordinal) + 1).Replace(".tn", "");
            var cg = new CodeGenerator(asmName);
            cg.Generate(root);
            cg.WriteAssembly();
            
            Console.Read();
        }

        private static void ShowUsage ()
        {
            Console.WriteLine("Usage:");
            Console.WriteLine("  tc.exe sourceFile [sourceFile [...]]");
        }
    }
}
