from typing import Any, Text, Dict, List

from rasa_sdk import Action, Tracker, FormValidationAction
from rasa_sdk.executor import CollectingDispatcher

class ActionUserName(Action):

    def name(self) -> Text:
        return "action_user_name"

    def run(self, dispatcher: CollectingDispatcher,
             tracker: Tracker,
             domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        dispatcher.utter_message(text="Hello! Welcome to NDB..")
        
        return []
    
class ActionvalidateName(FormValidationAction):

    def name(self) -> Text:
        return "validate_name_form"
    
    def validate_name(self,slot_value: Any,
                        dispatcher: CollectingDispatcher,
                        tracker: Tracker,
                        domain: Dict[Text, Any]) -> Dict[Text, Any]:

        name = slot_value.strip()

        if len(name) <= 2:
            print(f"Invalid name: {name}")
            dispatcher.utter_message(text="The name is too short. Please enter a valid name.")
            return {"name": None}
        
        elif not name[0].isupper():
            print(f"Invalid name: {name}")
            dispatcher.utter_message(text="The name must start with an uppercase letter.")
            return {"name": None}
        
        dispatcher.utter_message(text=f"Nice to meet you, {name}!")
        print(f"Valid name: {name}")
        return {"name": name}

class ActionUserAge(Action):

    def name(self) -> Text:
        return "action_user_age"

    def run(self, dispatcher: CollectingDispatcher,
             tracker: Tracker,
             domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        dispatcher.utter_message(text="How old are you?")
        
        return []
    
class ActionUserDetails(Action):

    def name(self) -> Text:
        return "action_user_details"

    def run(self, dispatcher: CollectingDispatcher,
             tracker: Tracker,
             domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        name = tracker.get_slot("name")
        age = tracker.get_slot("age")
        
        dispatcher.utter_message(text=f"Thank you {name}, you are {age} years old")
        
        return []