package com.fit5120ta28;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;

@RunWith(SpringRunner.class)
@SpringBootTest
public class AnimalsspeakApplicationTests {

	@Test
	public void contextLoads() throws Exception {
		csvTest1();
	}
	
	public void csvTest1() throws Exception {
		//File outfile = new File("datasets/Koala2.csv");//存储到新文件的路径
		 int count = 0;
		  try {
		   InputStreamReader isr = new InputStreamReader(new FileInputStream("datasets/Red Kangroo.csv"));//待处理数据的文件路径
		   BufferedReader reader = new BufferedReader(isr);
		   //BufferedWriter bw = new BufferedWriter(new FileWriter(outfile));
		   String line = null;
		  
		   while((line=reader.readLine())!=null){
			    
			   /*
			    if((line=reader.readLine())==null) {
			    	continue;
			    }*/
			    
                String item[] = line.split(",");
                System.out.println(item.length);
                if(item.length!=2) {
			    	continue;
			    }
                
                System.out.println(item[0]);
                
                //bw.newLine();//新起一行
                //bw.write(""+","+"");//写到新文件中
                
                if(item[0].equalsIgnoreCase("end")) {
                	break;
                }
                
                count++;
                System.out.println(count);
            }
		   System.out.println("abc");
		   System.out.println(count);
		   reader.close();
		   //bw.close();
		  } catch (Exception e) {
		   // TODO Auto-generated catch block
			  System.out.println(count);
		   e.printStackTrace();
		  }

	}
	
	
	
}
