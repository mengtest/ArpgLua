import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;


public class RC4Generate 
{

	public static void main(String []args)
	{
		rc4LuaWriteFile("/Users/zentertain/Documents/Project/cocos2d-x/projects/SlotsSaga3/Resources/core.lua",
				"/Users/zentertain//Documents/Project/cocos2d-x/projects/SlotsSaga3/Resources/common/core.a");
	    		
		String bigPath = args[0];// "/Users/zentertain/Documents/Project/cocos2d-x-v2/projects/BigCasino/config/";
		String bigDstPath = args[1]; //"/Users/zentertain/Documents/Project/cocos2d-x-v2/projects/BigCasino/Resources/config/";
		rc4LuaWriteDirectory(bigPath, bigDstPath);
	}
	
	public static void rc4LuaWriteDirectory(String srcPath, String dstPath)
	{
		if(!srcPath.endsWith("/")) srcPath = srcPath + "/";
		if(!dstPath.endsWith("/")) dstPath = dstPath + "/";
		File fileList = new File(srcPath);
		try
		{
		 	String[] filelist = fileList.list();
            for (int i = 0; i < filelist.length; i++) 
            {
            	String reStr = filelist[i];
            	File tmpFile = new File(srcPath+reStr);
            	if(tmpFile.isDirectory())
            	{
            		rc4LuaWriteDirectory(srcPath+reStr,dstPath+reStr);
            	}
            	else
            	{
            		//System.out.println(reStr);
                	rc4LuaWriteFile(srcPath+reStr,dstPath+reStr);
            	}
            	
            }
		}
		finally
		{
			
		}
	}
	
	public static void rc4LuaWriteFile(String srcPath, String dstPath)
	{
		File dstFile = new File(dstPath);
		File srcFile = new File(srcPath);
		dstFile.delete();
		dstFile = new File(dstPath);
		try {
			FileReader fReader = new FileReader(srcFile);
			BufferedReader fBufferReader = new BufferedReader(new InputStreamReader(new FileInputStream(srcFile), "utf-8"));  
			
			DataOutputStream dos =new DataOutputStream(new FileOutputStream(dstFile));
			char[] buffer = new char[(int) srcFile.length()];
			fBufferReader.read(buffer);
			byte[] bytes = new byte[(int) srcFile.length()];
			for(int i = 0; i < bytes.length; i++)
			{
				bytes[i] = (byte) buffer[i];
			}
			byte[] rc4Bytes = RC4.encrypt(bytes, bytes.length);
			char[] buffer2 = new char[(int) rc4Bytes.length];
			for(int i = 0; i < rc4Bytes.length; i++)
			{
				buffer2[i] = (char) rc4Bytes[i];
			}

			dos.write(rc4Bytes);

			dos.flush();
			fBufferReader.close();  
			fReader.close();
			dos.close();
			
			System.out.println("rc4 file " + srcPath + "---- to ----" + dstPath);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}  

	}
}
