/*********************************************************************************************************************
Class Name    : SalesforceIdTransform
Version       : 1.0
Created Date  : Apr 2023  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shivam Vishwakarma        27-Apr-2023             Contains Methods for Salesforce Id Transformation from 15 to 18 Characters & Validating the Checksum.
* ---------------------------------------------------------------------------------------------------------
References:
---------------------------------------------------------------------------------------------------------
Id Class : https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_id.htm
Pattern Class : https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_pattern_and_matcher_pattern_methods.htm
Type Class : https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_type.htm#apex_methods_system_type
SObject Class: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_sobject.htm
Detailed Description about Salesforce Ids : https://astadiaemea.wordpress.com/2010/06/21/15-or-18-character-ids-in-salesforce-com-%E2%80%93-do-you-know-how-useful-unique-ids-are-to-your-development-effort/
* *********************************************************************************************************************/
public class SalesforceIdTransform {
    
    /*
get15DigitId(id18Digits) --> Converts an 18-character Id value to a 15-character case-sensitive string.
*/
    public static String get15DigitId(Id id18Digits){
        System.debug('Got -->'+id18Digits);
        return id18Digits.to15();
    }
    
    
    /*
validSalesforceId_Check(idToCheck) --> Checks if the provided Id follows the pattern of a valid salesforce Id or Not.
*/
    public static Boolean validSalesforceId_Check(String idToCheck){
        Pattern salesforceIdPattern = Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}');
        if( salesforceIdPattern.matcher( idToCheck ).matches() ==true )
            return true;
        else
            return false;
    }
   
    
    /*
validId_ObjectType_Check(idToCheck,objectType) --> Checks if the provided Id follows the pattern of a valid salesforce Id & Id is of the provided sObject type or not.
Examples. 
System.debug( Utility.validId_ObjectType_Check('0015g000003xKvrAAE','Account') );
System.debug( Utility.validId_ObjectType_Check('a005g00002tLuxaAAC','Computer__c') );
*/
    public static Boolean validId_ObjectType_Check(String idToCheck, String sObjectTypeName){
        if( validSalesforceId_Check(idToCheck) == true ){
            try{
                Id IdfromString = Id.valueOf(idToCheck);  //Converts the specified String into an ID and returns the ID.
                //System.debug('Schema Global describe: '+Schema.getGlobalDescribe().get(sObjectTypeName) + ' , SobjectType of Id: '+IdfromString.getSobjectType() );
                if( IdfromString.getSobjectType() == Schema.getGlobalDescribe().get(sObjectTypeName)  )
                    return true;
                else
                    return false;                
            }catch(Exception e){
                System.debug('#### Some error occurred: '+e.getMessage());
                return false;
            }   
        }
        else
            return false;
    }    
    
    
    /*
valid18DigitsId_withChecksumCheck(idToCheck) --> Checks if the provided 18 digits salesforce Id follows the pattern of a valid salesforce Id or Not & checks if the last 3 characters checksum is valid or not.
*/
    public static Boolean valid18DigitsId_withChecksumCheck(String idToCheck){
        Pattern salesforceIdPattern = Pattern.compile('[a-zA-Z0-9]{18}');
        if( salesforceIdPattern.matcher( idToCheck ).matches() ==true ){
            //Necessary Data
            Map<String,String> lookupCharactersMap = new Map<String,String>();
            lookupCharactersMap.put('00000','A');  lookupCharactersMap.put('00001','B');  lookupCharactersMap.put('00010','C');  lookupCharactersMap.put('00011','D');  
            lookupCharactersMap.put('00100','E');  lookupCharactersMap.put('00101','F');  lookupCharactersMap.put('00110','G');  lookupCharactersMap.put('00111','H');  
            lookupCharactersMap.put('01000','I');  lookupCharactersMap.put('01001','J');  lookupCharactersMap.put('01010','K');  lookupCharactersMap.put('01011','L');  
            lookupCharactersMap.put('01100','M');  lookupCharactersMap.put('01101','N');  lookupCharactersMap.put('01110','O');  lookupCharactersMap.put('01111','P');  
            lookupCharactersMap.put('10000','Q');  lookupCharactersMap.put('10001','R');  lookupCharactersMap.put('10010','S');  lookupCharactersMap.put('10011','T');  
            lookupCharactersMap.put('10100','U');  lookupCharactersMap.put('10101','V');  lookupCharactersMap.put('10110','W');  lookupCharactersMap.put('10111','X');  
            lookupCharactersMap.put('11000','Y');  lookupCharactersMap.put('11001','Z');  lookupCharactersMap.put('11010','0');  lookupCharactersMap.put('11011','1');  
            lookupCharactersMap.put('11100','2');  lookupCharactersMap.put('11101','3');  lookupCharactersMap.put('11110','4');  lookupCharactersMap.put('11111','5'); 
            
            //Step 1: Split the 15 digit Id into 3 blocks of 5 digits
            String block1 = idToCheck.substring(0, 5);
            String block2 = idToCheck.substring(5, 10);
            String block3 = idToCheck.substring(10, 15);
            
            //Step 2: Reverse the blocks
            block1 = block1.reverse();
            block2 = block2.reverse();
            block3 = block3.reverse();
            String combinedBlocks = block1+block2+block3;
            
            //Step 3:Generate lookup key blocks based on if each character is in Uppercase(1) or Lowercase/numeric(0)
            String combinedLookupBlocks='';
            for(Integer i=0; i<combinedBlocks.length() ; i++){
                String bitval = combinedBlocks.substring(i,i+1).isAllUpperCase() ? '1':'0';
				combinedLookupBlocks += bitval;                
            }
            String lookupBlock1 = combinedLookupBlocks.substring(0, 5);
            String lookupBlock2 = combinedLookupBlocks.substring(5, 10);
            String lookupBlock3 = combinedLookupBlocks.substring(10, 15);
            
            //Step 4: Check Lookup Map & determine the Checksum & check it with the Checksum obtained in input String (last 3 characters of 18 digit Id)
            String calculatedChecksum = lookupCharactersMap.get(lookupBlock1) + lookupCharactersMap.get(lookupBlock2) + lookupCharactersMap.get(lookupBlock3);
            System.debug('@@calculatedChecksum: '+calculatedChecksum);
            String inputProvidedChecksum = idToCheck.substring(15, 18);
            if(calculatedChecksum == inputProvidedChecksum)
                return true;
            else 
                return false;
        }    
        else
            return false;
    } 
    
    
    /*
convert15To18CharsId(idToCheck) --> Convert 15 chars Salesforce Id into 18 chars Salesforce Id.
*/
    public static String convert15To18CharsId(String idToCheck){
        Pattern salesforceIdPattern = Pattern.compile('[a-zA-Z0-9]{15}');
        if( salesforceIdPattern.matcher( idToCheck ).matches() ==true ){
            //Necessary Data
            Map<String,String> lookupCharactersMap = new Map<String,String>();
            lookupCharactersMap.put('00000','A');  lookupCharactersMap.put('00001','B');  lookupCharactersMap.put('00010','C');  lookupCharactersMap.put('00011','D');  
            lookupCharactersMap.put('00100','E');  lookupCharactersMap.put('00101','F');  lookupCharactersMap.put('00110','G');  lookupCharactersMap.put('00111','H');  
            lookupCharactersMap.put('01000','I');  lookupCharactersMap.put('01001','J');  lookupCharactersMap.put('01010','K');  lookupCharactersMap.put('01011','L');  
            lookupCharactersMap.put('01100','M');  lookupCharactersMap.put('01101','N');  lookupCharactersMap.put('01110','O');  lookupCharactersMap.put('01111','P');  
            lookupCharactersMap.put('10000','Q');  lookupCharactersMap.put('10001','R');  lookupCharactersMap.put('10010','S');  lookupCharactersMap.put('10011','T');  
            lookupCharactersMap.put('10100','U');  lookupCharactersMap.put('10101','V');  lookupCharactersMap.put('10110','W');  lookupCharactersMap.put('10111','X');  
            lookupCharactersMap.put('11000','Y');  lookupCharactersMap.put('11001','Z');  lookupCharactersMap.put('11010','0');  lookupCharactersMap.put('11011','1');  
            lookupCharactersMap.put('11100','2');  lookupCharactersMap.put('11101','3');  lookupCharactersMap.put('11110','4');  lookupCharactersMap.put('11111','5'); 
            
            //Step 1: Split the 15 digit Id into 3 blocks of 5 digits
            String block1 = idToCheck.substring(0, 5);
            String block2 = idToCheck.substring(5, 10);
            String block3 = idToCheck.substring(10, 15);
            
            //Step 2: Reverse the blocks
            block1 = block1.reverse();
            block2 = block2.reverse();
            block3 = block3.reverse();
            String combinedBlocks = block1+block2+block3;
            
            //Step 3:Generate lookup key blocks based on if each character is in Uppercase(1) or Lowercase/numeric(0)
            String combinedLookupBlocks='';
            for(Integer i=0; i<combinedBlocks.length() ; i++){
                String bitval = combinedBlocks.substring(i,i+1).isAllUpperCase() ? '1':'0';
				combinedLookupBlocks += bitval;                
            }
            String lookupBlock1 = combinedLookupBlocks.substring(0, 5);
            String lookupBlock2 = combinedLookupBlocks.substring(5, 10);
            String lookupBlock3 = combinedLookupBlocks.substring(10, 15);
            
            //Step 4: Check Lookup Map & determine the Checksum & check it with the Checksum obtained in input String (last 3 characters of 18 digit Id)
            String calculatedChecksum = lookupCharactersMap.get(lookupBlock1) + lookupCharactersMap.get(lookupBlock2) + lookupCharactersMap.get(lookupBlock3);
            System.debug('@@calculatedChecksum: '+calculatedChecksum);          
            return (idToCheck+calculatedChecksum);
        }    
        else
            return 'Not a Valid 15 Characters Salesforce Id.';
    } 
        

} //End of Class
