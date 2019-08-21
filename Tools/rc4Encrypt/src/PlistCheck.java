import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.nio.channels.FileChannel;

public class PlistCheck {
	static String md5Dir = "/Users/zentertain/Desktop/subjectMd5/";
	static String ccbDir = "/Users/zentertain/Desktop/subjectCCB/";
	public static void main(String []args)
	{
//		if (args.length < 2)
//		{
//			for (int i = 0; i < args.length; ++ i)
//				System.out.println(args[i]);
//			return;
//		}
//		renameFiles();
//		Function1();
		plistCheck();
	}
	
	public static void plistCheck()
	{
		
		File fileList = new File(md5Dir);
		BufferedReader bf = null;
		try
		{
		 	String[] filelist = fileList.list();
            for (int i = 0; i < filelist.length; i++) 
            {
            	String subjectName = filelist[i];
            	System.out.println(subjectName);
            	
                try {
                	File srcFile = new File(md5Dir + filelist[i] + "/files.md5");
                	FileReader fReader = new FileReader(srcFile);  
            		BufferedReader fBufferReader = new BufferedReader(fReader);  
            		while (fBufferReader.ready()) 
            		{  
                		String line = fBufferReader.readLine();
                		if(line.indexOf(".ccbi") > 0)
                		{
                			String ccbFile = line.substring(0, line.indexOf(".ccbi"));
                			checkSubject(subjectName, ccbFile);
                		}
            		}  
            		fBufferReader.close();  
            		fReader.close();

                } catch (IOException e) 
                {
                    e.printStackTrace();
                }
            }
		}
		finally
		{
			if (bf != null)
			{
				try
				{
					bf.close();
				} catch (IOException e)
				{
					e.printStackTrace();
				}
			}
		}
	}
	
	public static void checkSubject(String subjectName, String ccbFile)
	{
    	File srcFile = new File(ccbDir + ccbFile + ".ccb");
        
        try {

        	FileReader fReader = new FileReader(srcFile);  
    		BufferedReader fBufferReader = new BufferedReader(fReader);  
    		while (fBufferReader.ready()) 
    		{  
        		String line = fBufferReader.readLine();
        		if(line.indexOf(".jpg") >= 0 || line.indexOf(".png") >= 0|| line.indexOf(".plist") >= 0)
        		{
        			String file = line.substring(line.indexOf("<string>")+ "<string>".length());
        			file = file.substring(0, file.indexOf("</string>"));
        			if(file.indexOf("/") >= 0)
        			{
        				String dir = file.substring(0, file.indexOf("/"));
        				if(!dir.equalsIgnoreCase(subjectName) && !dir.equalsIgnoreCase("common") && !dir.equalsIgnoreCase("slot"))
        				{
        					String output = subjectName + "\t" + ccbFile + "\t" + file;
        					System.out.println(output);
        				}
        			}
        				
        		}
    		}  
    		fBufferReader.close();  
    		fReader.close();

        } catch (IOException e) 
        {
            e.printStackTrace();
        }

	}

}
