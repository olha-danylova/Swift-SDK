//
//  MapDrivenDataStore.swift
//
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2020 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

@objcMembers public class MapDrivenDataStore: NSObject, IDataStore {
    
    typealias CustomType = [String : Any]
    
    public var rt: EventHandlerForMap!
    public private(set) var isOfflineAutoSyncEnabled = false
    
    private var tableName: String
    private var persistenceServiceUtils: PersistenceServiceUtils
    private var persistenceServiceUtilsLocal: PersistenceServiceUtilsLocal
    
    init(tableName: String) {
        self.tableName = tableName
        self.rt = RTFactory.shared.createEventHandlerForMap(tableName: tableName)        
        persistenceServiceUtils = PersistenceServiceUtils(tableName: self.tableName)
        persistenceServiceUtilsLocal = PersistenceServiceUtilsLocal(tableName: tableName)
    }
    
    public func save(entity: [String : Any], responseHandler: (([String : Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        if entity["objectId"] != nil {
            update(entity: entity, responseHandler: responseHandler, errorHandler: errorHandler)
        }
        else {
            create(entity: entity, responseHandler: responseHandler, errorHandler: errorHandler)
        }
    }
    
    public func create(entity: [String : Any], responseHandler: (([String : Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.create(entity: entity as [String : AnyObject], responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func createBulk(entities: [[String : Any]], responseHandler: (([String]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.createBulk(entities: entities, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func update(entity: [String : Any], responseHandler: (([String : Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.update(entity: entity, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func updateBulk(whereClause: String?, changes: [String : Any], responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.updateBulk(whereClause: whereClause, changes: changes, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func removeById(objectId: String, responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.removeById(objectId: objectId, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func remove(entity: [String : Any], responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        if let objectId = entity["objectId"] as? String {
            persistenceServiceUtils.removeById(objectId: objectId, responseHandler: responseHandler, errorHandler: errorHandler)
        }
    }
    
    public func removeBulk(whereClause: String?, responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.removeBulk(whereClause: whereClause, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func getObjectCount(responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.getObjectCount(queryBuilder: nil, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func getObjectCount(queryBuilder: DataQueryBuilder, responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.getObjectCount(queryBuilder: queryBuilder, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func find(responseHandler: (([[String : Any]]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.find(queryBuilder: nil, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func find(queryBuilder: DataQueryBuilder, responseHandler: (([[String : Any]]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.find(queryBuilder: queryBuilder, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func findFirst(responseHandler: (([String : Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.findFirstOrLastOrById(first: true, last: false, objectId: nil, queryBuilder: nil, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func findFirst(queryBuilder: DataQueryBuilder, responseHandler: (([String : Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.findFirstOrLastOrById(first: true, last: false, objectId: nil, queryBuilder: queryBuilder, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func findLast(responseHandler: (([String : Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.findFirstOrLastOrById(first: false, last: true, objectId: nil, queryBuilder: nil, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func findLast(queryBuilder: DataQueryBuilder, responseHandler: (([String : Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.findFirstOrLastOrById(first: false, last: true, objectId: nil, queryBuilder: queryBuilder, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func findById(objectId: String, responseHandler: (([String : Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.findFirstOrLastOrById(first: false, last: false, objectId: objectId, queryBuilder: nil, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func findById(objectId: String, queryBuilder: DataQueryBuilder, responseHandler: (([String : Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.findFirstOrLastOrById(first: false, last: false, objectId: objectId, queryBuilder: queryBuilder, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func setRelation(columnName: String, parentObjectId: String, childrenObjectIds: [String], responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.setOrAddRelation(columnName: columnName, parentObjectId: parentObjectId, childrenObjectIds: childrenObjectIds, httpMethod: .post, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func setRelation(columnName: String, parentObjectId: String, whereClause: String?, responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.setOrAddRelation(columnName: columnName, parentObjectId: parentObjectId, whereClause: whereClause, httpMethod: .post, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func addRelation(columnName: String, parentObjectId: String, childrenObjectIds: [String], responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.setOrAddRelation(columnName: columnName, parentObjectId: parentObjectId, childrenObjectIds: childrenObjectIds, httpMethod: .put, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func addRelation(columnName: String, parentObjectId: String, whereClause: String?, responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.setOrAddRelation(columnName: columnName, parentObjectId: parentObjectId, whereClause: whereClause, httpMethod: .put, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func deleteRelation(columnName: String, parentObjectId: String, childrenObjectIds: [String], responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.deleteRelation(columnName: columnName, parentObjectId: parentObjectId, childrenObjectIds: childrenObjectIds, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func deleteRelation(columnName: String, parentObjectId: String, whereClause: String?, responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.deleteRelation(columnName: columnName, parentObjectId: parentObjectId, whereClause: whereClause, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func loadRelations(objectId: String, queryBuilder: LoadRelationsQueryBuilder, responseHandler: (([[String : Any]]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.loadRelations(objectId: objectId, queryBuilder: queryBuilder, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    // *************************************************
    
    public func initLocalDatabase(whereClause: String, responseHandler: (() -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtilsLocal.initLocalDatabase(whereClause: whereClause, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func clearLocalDatabase() {
        persistenceServiceUtilsLocal.clearLocalDatabase()
    }
    
    public func enableOfflineSync() {
        isOfflineAutoSyncEnabled = true
        OfflineSyncManager.shared.autoSyncTables.append(self.tableName)
    }
    
    public func disableOfflineSync() {
        isOfflineAutoSyncEnabled = false
        OfflineSyncManager.shared.autoSyncTables.removeObject(self.tableName)
        OfflineSyncManager.shared.removeSyncOperations(tableName: self.tableName)
    }
    
    public func onSave(_ onSaveCallback: OnSave) {
        OfflineSyncManager.shared.onSaveCallbacks[tableName] = onSaveCallback
    }
    
    public func onRemove(_ onRemoveCallback: OnRemove) {
        OfflineSyncManager.shared.onRemoveCallbacks[tableName] = onRemoveCallback
    }
    
    public func saveEventually(entity: [String : Any]) {
        persistenceServiceUtilsLocal.saveEventually(entity: entity, callback: nil)
    }
    
    public func saveEventually(entity: [String : Any], callback: OfflineAwareCallback) {
        persistenceServiceUtilsLocal.saveEventually(entity: entity, callback: callback)
    }
    
    public func removeEventually(entity: [String : Any]) {
        persistenceServiceUtilsLocal.removeEventually(entity: entity, callback: nil)
    }
    
    public func removeEventually(entity: [String : Any], callback: OfflineAwareCallback) {
        persistenceServiceUtilsLocal.removeEventually(entity: entity, callback: callback)
    }
}
