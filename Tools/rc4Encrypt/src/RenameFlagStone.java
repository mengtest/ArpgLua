
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

public class RenameFlagStone 
{
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
		Function2();
	}
	
	public static void renameFiles()
	{
		String documentName = "2";
		String srcDir = "/Users/zentertain/Desktop/sound/"+documentName;
		if (srcDir.lastIndexOf("/") != (srcDir.length() - 1))
			srcDir += "/";
		String destDir = "/Users/zentertain/Desktop/bingoSound/"+documentName;
		if (destDir.lastIndexOf("/") != (destDir.length() - 1))
			destDir += "/";
		File fileList = new File(srcDir);
		BufferedReader bf = null;
		try
		{
		 	String[] filelist = fileList.list();
            for (int i = 0; i < filelist.length; i++) 
            {
            	String reStr = filelist[i];
            	System.out.println(reStr);
            	File srcFile = new File(srcDir + filelist[i]);
            	String name = filelist[i];
            	if(name.charAt(0) <='z' && name.charAt(0) >='a' && name.charAt(1) <='9' && name.charAt(1) >='0')
            	{
            		name = name.substring(1);
            	}
            	File destFilePath = new File(destDir + documentName + "_" + name);
            	FileInputStream fi = null;
                FileOutputStream fo = null;
                FileChannel in = null;
                FileChannel out = null;
                try {

                    fi = new FileInputStream(srcFile);
                    fo = new FileOutputStream(destFilePath);
                    in = fi.getChannel();//得到对应的文件通道
                    out = fo.getChannel();//得到对应的文件通道
                    in.transferTo(0, in.size(), out);//连接两个通道，并且从in通道读取，然后写入out通道

                } catch (IOException e) 
                {
                    e.printStackTrace();
                } finally {
                    try {
                        fi.close();
                        in.close();
                        fo.close();
                        out.close();
                    } catch (IOException e)
                    {
                        e.printStackTrace();
                    }
                }
            }
//            	FileReader fReader = new FileReader(srcFile);  
//        		BufferedReader fBufferReader = new BufferedReader(fReader);  
//        		
//        		FileWriter fWriter = new FileWriter(destFilePath);
//        		BufferedWriter fBufferWriter = new BufferedWriter(fWriter);
//    			char[] buffer = new char[(int) srcFile.length()];
//        		fBufferReader.read(buffer);
//        		fBufferWriter.write(buffer);
//  
//        		fBufferWriter.flush();
//        		fBufferReader.close();  
//        		fReader.close();
//        		fWriter.close();
//        		fBufferWriter.close();
//			}	
			
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
	
	public static void Function1()
	{
		String srcDir = "/Users/zentertain/Desktop/lobby";
		if (srcDir.lastIndexOf("/") != (srcDir.length() - 1))
			srcDir += "/";
		String destDir = "/Users/zentertain/Desktop/lobby_rename";
		if (destDir.lastIndexOf("/") != (destDir.length() - 1))
			destDir += "/";
		File fileList = new File(srcDir);
		BufferedReader bf = null;
		try
		{
		 	String[] filelist = fileList.list();
            for (int i = 0; i < filelist.length; i++) 
            {
            	String reStr = filelist[i];
            	reStr = reStr.substring(0,reStr.indexOf("_"));
            	
            	reStr += "_flagstone";
            	System.out.println(reStr);
            	File srcFile = new File(srcDir + filelist[i]);
            	File destFilePath = new File(destDir + filelist[i]);
            	
            	FileReader fReader = new FileReader(srcFile);  
        		BufferedReader fBufferReader = new BufferedReader(fReader);  
        		
        		FileWriter fWriter = new FileWriter(destFilePath);
        		BufferedWriter fBufferWriter = new BufferedWriter(fWriter);
        		while (fBufferReader.ready()) 
        		{  
            		String line = fBufferReader.readLine();
            		line = line.replace("Sculpture_world1", reStr);
            		line = line.replace("Sculpture_world2", reStr);
            		line = line.replace("Sculpture_world3", reStr);
 //           		line = line.replace("Sculpture_world3", reStr);
            		line = line.replace("Sculpture_normal", reStr);
            		line = line.replace("Sculpture_ccb", reStr);
            		
            		fBufferWriter.newLine();
            		fBufferWriter.write(line);
        		}  
        		fBufferWriter.flush();
        		fBufferReader.close();  
        		fReader.close();
        		fWriter.close();
        		fBufferWriter.close();
			}	
			
		} catch (FileNotFoundException e)
		{
			e.printStackTrace();
		} catch (IOException e)
		{
			e.printStackTrace();
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
	
	public static void Function2()
	{
		String srcDir = "/Users/zentertain/Desktop/bingo_common";
		if (srcDir.lastIndexOf("/") != (srcDir.length() - 1))
			srcDir += "/";
		String destDir = "/Users/zentertain/Desktop/new_bingo_common";
		if (destDir.lastIndexOf("/") != (destDir.length() - 1))
			destDir += "/";
		File fileList = new File(srcDir);
		BufferedReader bf = null;
		try
		{
		 	String[] filelist = fileList.list();
            for (int i = 0; i < filelist.length; i++) 
            {
//            	String reStr = filelist[i];
//            	reStr = reStr.substring(0,reStr.indexOf("_"));
//            	
//            	reStr += "_flagstone";
//            	System.out.println(reStr);
            	File srcFile = new File(srcDir + filelist[i]);
            	File destFilePath = new File(destDir + filelist[i]);
            	
            	FileReader fReader = new FileReader(srcFile);  
        		BufferedReader fBufferReader = new BufferedReader(fReader);  
        		
        		FileWriter fWriter = new FileWriter(destFilePath);
        		BufferedWriter fBufferWriter = new BufferedWriter(fWriter);
        		while (fBufferReader.ready()) 
        		{  
            		String line = fBufferReader.readLine();
            		line = line.replace("bingo/common/", "bingo_common/");
            		fBufferWriter.newLine();
            		fBufferWriter.write(line);
        		}  
        		fBufferWriter.flush();
        		fBufferReader.close();  
        		fReader.close();
        		fWriter.close();
        		fBufferWriter.close();
			}	
			
		} catch (FileNotFoundException e)
		{
			e.printStackTrace();
		} catch (IOException e)
		{
			e.printStackTrace();
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

}
