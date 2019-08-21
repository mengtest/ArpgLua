

/**
 * 
 * This is a class that Implements the RC4 encryption algorithm.
 * 
 * 
 * @author EJJ
 * @date Feb 16, 2012
 */
public class RC4
{
	//The name of INKEY or OUTKEY is defined on the condition of server and client
	//In the case of servers all of which include this same file,
	//if encryption is needed, one using encrypt method to encrypt and others need
	//using encrypt method to decrypt as well. That is, to encrypt and decrypt a string should use the same key
	private static String OUTKEY = "234*&re)(@~!`f><?:;',,%%$=+_";	
    private static String INKEY = "&%^sjdfwiewr%$#123#)(+_/,:.><";	
	
    private static class RC4State
	{
		public int[] perm = new int[256];
		public int index1;
		public int index2;
	}
	
	private RC4State rc4State = new RC4State();
    
	public RC4()
	{
	}

	/**
	 * RC4 Encryption
	 * 
	 * @param plaintext
	 * @return
	 */
	public static byte[] encrypt(byte[] plaintext, int len)
	{
		return encrypt(plaintext, 0, len);
	}
	
	public static byte[] encrypt(byte[] plaintext, int offset, int len)
	{
		RC4 encoder = new RC4();
		encoder.rc4Init(OUTKEY.getBytes());
		return encoder.rc4Crypt(plaintext, offset, len);
	}

	public static byte[] encrypt(String plaintext)
	{
		byte[] plainBytes = plaintext.getBytes();
		RC4 encoder = new RC4();
		encoder.rc4Init(OUTKEY.getBytes());
		return encoder.rc4Crypt(plainBytes, 0, plainBytes.length);
	}
	
	/**
	 * Same as encryption
	 * 
	 * @param ciphertext
	 * @return
	 */
	public static byte[] decrypt(byte[] ciphertext, int len)
	{
		RC4 decoder = new RC4();
		decoder.rc4Init(INKEY.getBytes());
		return decoder.rc4Crypt(ciphertext, 0, len);
	}
	
	public static byte[] decrypt(byte[] ciphertext, int offset, int len)
	{
		RC4 decoder = new RC4();
		decoder.rc4Init(INKEY.getBytes());
		return decoder.rc4Crypt(ciphertext, offset, len);
	}
	
	private void rc4Init(byte[] keyBytes)
	{
		int j;
		int i;
		int keylen = keyBytes.length;
	    
		/* Initialize state with identity permutation */
		for (i = 0; i < 256; i++)
		{
			rc4State.perm[i] = i;
		}
		rc4State.index1 = 0;
		rc4State.index2 = 0;
	    
		/* Randomize the permutation using key data */
		for (j = 0, i = 0; i < 256; i++) 
		{
			j += rc4State.perm[i] + keyBytes[i % keylen];
			j = j & 0xff;
			int tmp = rc4State.perm[i] & 0xff;
			rc4State.perm[i] = rc4State.perm[j] & 0xff;
			rc4State.perm[j] = tmp;
		}
	}
	
	private byte[] rc4Crypt(byte[] inBytes, int offset, int len)
	{
		int i;
		int j;
	    byte[] outBuf = new byte[offset + len];
		
		for (i = offset; i < offset + len; i++)
		{
	        
			/* Update modification indicies */
			rc4State.index1 = (rc4State.index1 + 1) & 0xff;
			rc4State.index2 = (rc4State.index2 + rc4State.perm[rc4State.index1]) & 0xff;
			
			/* Modify permutation */
	        int tmp = rc4State.perm[rc4State.index1] & 0xff;
	        rc4State.perm[rc4State.index1] = rc4State.perm[rc4State.index2] & 0xff;
			rc4State.perm[rc4State.index2] = tmp;
	        
			/* Encrypt/decrypt next byte */
			j = (rc4State.perm[rc4State.index1] + rc4State.perm[rc4State.index2]) & 0xff;
			outBuf[i] = (byte)(inBytes[i] ^ rc4State.perm[j]);
		}
		return outBuf;
	}
	
//	public static void main(String[] args) {
//		String str = "abc123";
//		byte[] strByte = str.getBytes();
//		byte[] bytes = new byte[4+strByte.length];
//		for(int i = 0; i < strByte.length; i++) {
//			bytes[i+4] = strByte[i];
//		}
//		byte[] encrypted = decrypt(bytes, 4, strByte.length);
//		byte[] plain = decrypt(encrypted, 4, strByte.length);
//		System.out.println(new String(plain, 4, strByte.length));
//	}
}
