import java.io.*;
import java.util.*;
import java.util.regex.*;

/**
 * NLP utility class for tokenizing a sentence into words.
 * This is the port of tokenizer.sed script from Penn Treebank
 * http://www.cis.upenn.edu/~treebank/tokenizer.sed
 * to Java.
 */
public class Tokenizer
{
  public static void main(String[] args)
  {
    try
    {
      BufferedReader br = new BufferedReader(new FileReader(args[0]));
      BufferedWriter bw = new BufferedWriter(new FileWriter(args[1]));
      String s;
      while((s = br.readLine() )!= null)
      {
        String[] tokens = Tokenizer.tokenize(s);
        for(int i = 0 ; i < tokens.length ; i++)
        {
          bw.write(tokens[i]);
          if (i < tokens.length - 1)
            bw.write(" ");
        }
        bw.write("\n");
      }
      bw.close();
      br.close();
    } catch (Exception e)
    {
      System.out.println(e);
      System.exit(-1);
    }
  }
	public static String [] tokenize (String context)
	{
		context = 
			tokenizeRule7 (
			tokenizeRule6 (
			tokenizeRule5 (
			tokenizeRule4 (
			tokenizeRule3 (
			tokenizeRule2 (
			tokenizeRule1 (context)
			))))));
		
		return context.split ("\\s+");
		
	} // method tokenize
	
	public static String tokenizeRule1 (String context)
	{
		// s=^"=`` =g
		context = context.replaceAll ("^\"", "`` ");
		// s=\([ ([{<]\)"=\1 `` =g
		context = context.replaceAll ("([ \\(\\[{<])\"", "$1 `` ");
		return context;
	}
	
	public static String tokenizeRule2 (String context)
	{
		// s=\.\.\.= ... =g
		context = context.replaceAll ("\\.\\.\\.", " ... ");
		// s=[,;:@#$%&]= & =g
		context = context.replaceAll ("([,;:@#$%&])", " $1 ");
		return context;
	}
	
	public static String tokenizeRule3 (String context)
	{
		// s=\([^.]\)\([.]\)\([])}>"']*\)[ \t]*$=\1 \2\3 =g
		context = context.replaceAll (
			"([^.])([.])([\\]\\)}>\"']*)[ \t]*$",
			"$1 $2$3 ");
		// s=[?!]= & =g
		context = context.replaceAll ("([?!])", " $1 ");
		return context;
	}
	
	public static String tokenizeRule4 (String context)
	{
		// s=[][(){}<>]= & =g
		context = context.replaceAll (
			"([\\[\\]\\(\\)\\{\\}<>])",
			" $1 ");
		// s/(/-LRB-/g
		// s/)/-RRB-/g
		// s/\[/-LSB-/g
		// s/\]/-RSB-/g
		// s/{/-LCB-/g
		// s/}/-RCB-/g
		context = context.replaceAll ("\\(", "-LRB-");
		context = context.replaceAll ("\\)", "-RRB-");
		context = context.replaceAll ("\\[", "-LSB-");
		context = context.replaceAll ("\\]", "-RSB-");
		context = context.replaceAll ("\\{", "-LCB-");
		context = context.replaceAll ("\\}", "-RCB-");
		// s=--= -- =g
		context = context.replaceAll ("--", " -- ");
		return context;
	}
	
	public static String tokenizeRule5 (String context)
	{
		// s=$= =
		context = context.replaceAll ("$"," ");
		// s=^= =
		context = context.replaceAll ("^", " ");
		// s="= '' =g
		context = context.replaceAll ("\"", " '' ");
		// s=\([^']\)' =\1 ' =g
		context = context.replaceAll ("([^'])' ", "$1 ' ");
		// s=''= '' =g
		context = context.replaceAll ("''", " '' ");
		// s=``= `` =g
		context = context.replaceAll ("``", " `` ");
		return context;
	}
	
	public static String tokenizeRule6 (String context)
	{
		// s='\([sSmMdD]\) = '\1 =g
		context = context.replaceAll ("'([sSmMdD]) ", " '$1 ");
		// s='ll = 'll =g
		context = context.replaceAll ("'ll ", " 'll ");
		// s='re = 're =g
		context = context.replaceAll ("'re ", " 're ");
		// s='ve = 've =g
		context = context.replaceAll ("'ve ", " 've ");
		// s=n't = n't =g
		context = context.replaceAll ("n't ", " n't ");
		// s='LL = 'LL =g
		context = context.replaceAll ("'LL ", " 'LL ");
		// s='RE = 'RE =g
		context = context.replaceAll ("'RE ", " 'RE ");
		// s='VE = 'VE =g
		context = context.replaceAll ("'VE ", " 'VE ");
		// s=N'T = N'T =g
		context = context.replaceAll ("N'T ", " N'T ");
		return context;
	}
	
	public static String tokenizeRule7 (String context)
	{
		// s= \([Cc]\)annot = \1an not =g
		context = context.replaceAll (" ([Cc])annot ", " $1an not ");
		// s= \([Dd]\)'ye = \1' ye =g
		context = context.replaceAll (" ([Dd])'ye ", " $1' ye ");
		// s= \([Gg]\)imme = \1im me =g
		context = context.replaceAll (" ([Gg])imme ", " $1im me ");
		// s= \([Gg]\)onna = \1on na =g
		context = context.replaceAll (" ([Gg])onna ", " $1on na ");
		// s= \([Gg]\)otta = \1ot ta =g
		context = context.replaceAll (" ([Gg])otta ", " $1ot ta ");
		// s= \([Ll]\)emme = \1em me =g
		context = context.replaceAll (" ([Ll])emme ", " $1em me ");
		// s= \([Mm]\)ore'n = \1ore 'n =g
		context = context.replaceAll (" ([Mm])ore'n ", " $1ore 'n ");
		// s= '\([Tt]\)is = '\1 is =g
		context = context.replaceAll (" '([Tt])is ", " '$1 is ");
		// s= '\([Tt]\)was = '\1 was =g
		context = context.replaceAll (" '([Tt])was ", " '$1 was ");
		// s= \([Ww]\)anna = \1an na =g
		context = context.replaceAll (" ([Ww])anna ", " $1an na ");
		
		context = context.replaceAll ("^\\s+", "");
		context = context.replaceAll ("\\s+$", "");
		context = context.replaceAll ("\\s{2,}", " ");
		
		return context;
	}
	
} // class Tokenizer
