package com.bjpowernode.crm.poi;

import com.bjpowernode.crm.commons.utils.HSSFUtils;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import java.io.FileInputStream;
import java.io.InputStream;

public class PraseExcelTest {
    public static void main(String[] args)throws Exception {
        InputStream is = new FileInputStream("D:\\JAVA\\SSM-CRM\\upLoad\\myList.xls");

        HSSFWorkbook wb = new HSSFWorkbook(is);

        HSSFSheet sheet = wb.getSheetAt(0);

        HSSFRow row=null;
        HSSFCell cell=null;

        for(int i=0;i<=sheet.getLastRowNum();i++){
            row=sheet.getRow(i);
            for(int j=0;j<row.getLastCellNum();j++){
                cell=row.getCell(j);
                System.out.print(HSSFUtils.getCellValueForstr(cell)+" ");

            }
            System.out.println();
        }

    }
}
