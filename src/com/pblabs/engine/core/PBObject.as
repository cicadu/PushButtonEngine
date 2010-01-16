package com.pblabs.engine.core
{
    import com.pblabs.engine.PBE;

    /**
     * Base implementation of a named object that can exist in sets or groups.
     * 
     * @see IPBObject
     */
    public class PBObject implements IPBObject
    {
        protected var _name:String, _alias:String;
        protected var _owningGroup:PBGroup;
        protected var _sets:Array;
        
        internal function noteInSet(s:PBSet):void
        {
            if(!_sets)
                _sets = [];
            _sets.push(s);
        }
        
        internal function noteOutOfSet(s:PBSet):void
        {
            var idx:int = _sets.indexOf(s);
            if(idx == -1)
                throw new Error("Removed object from set that it isn't in.");
            _sets.splice(idx, 1);
        }
        
        public function get owningGroup():PBGroup
        {
            return _owningGroup;
        }

        public function set owningGroup(value:PBGroup):void
        {
            if(!value)
                throw new Error("Must always be in a group - cannot set owningGroup to null!");
            
            if(_owningGroup)
                _owningGroup.removeFromGroup(this);
            
            _owningGroup = value;
            _owningGroup.addToGroup(this);
        }

        public function get name():String
        {
            return _name;
        }
        
        public function get alias():String
        {
            return _alias;
        }

        public function initialize(name:String = null, alias:String = null):void
        {            
            // Note the names.
            _name = name;
            _alias = alias;
            
            // Register with the name manager.
            PBE.nameManager.add(this);
            
            // Put us in the current group if we have no group specified.
            if(owningGroup == null && PBE.currentGroup != this)
                owningGroup = PBE.currentGroup;
        }
        
        public function destroy():void
        {
            // Remove from the name manager.
            PBE.nameManager.remove(this);
            
            // Remove from our owning group.
            if(_owningGroup)
            {
                _owningGroup.removeFromGroup(this);
                _owningGroup = null;                
            }
            
            // Remove from any sets.
            while(_sets && _sets.length)
            {
                (_sets.pop() as PBSet).remove(this);
            }
        }
    }
}