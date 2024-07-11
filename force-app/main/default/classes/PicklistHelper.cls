/*
Description			:	
Test class			:	
*/

public class PicklistHelper {
    
    public static Map<Object, List<String>> getDependentPicklistValues(Schema.sObjectField dependentField) {
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        
        Schema.DescribeFieldResult dependentFieldResult = dependentField.getDescribe();
        Schema.sObjectField controllerField = dependentFieldResult.getController();
        
        if (controllerField == null) {
            return null;
        } 
        
        Schema.DescribeFieldResult controllerFieldResult = controllerField.getDescribe();
        
        List<Schema.PicklistEntry> controllerValues = (controllerFieldResult.getType() == Schema.DisplayType.Boolean 
                                                       ? null : controllerFieldResult.getPicklistValues());
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        
        for (Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()) {
            if (entry.isActive()) {
                List<String> base64chars = String.valueOf(((Map<String,Object>)JSON.deserializeUntyped
                                                           (JSON.serialize(entry))).get('validFor')).split('');
                
                for (Integer i = 0; i < controllerValues.size(); i++) {
                    Object controllerValue = (controllerValues == null ? (Object) (i == 1) 
                                              : (Object) (controllerValues[i].isActive() ? controllerValues[i].getLabel() : null));
                    Integer bitIndex = i / 6;
                    Integer bitShift = 5 - Math.mod(i, 6 );
                    
                    if (controllerValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0) {
                        continue;
                    } 
                    
                    if (!dependentPicklistValues.containsKey(controllerValue)) {
                        dependentPicklistValues.put(controllerValue, new List<String>());
                    }
                    
                    dependentPicklistValues.get(controllerValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }
    
}