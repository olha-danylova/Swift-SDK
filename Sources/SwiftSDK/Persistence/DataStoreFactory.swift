//
//  DataStoreFactory.swift
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

@objcMembers public class DataStoreFactory: NSObject, IDataStore {
    
    typealias CustomType = Any
    
    public var rt: EventHandlerForClass!
    
    public private(set) var isOfflineAutoSyncEnabled: Bool {
        get {
            if Backendless.shared.data.isOfflineAutoSyncEnabled, !(OfflineSyncManager.shared.dontSyncTables.contains(tableName)) {
                return true
            }
            else if OfflineSyncManager.shared.syncTables.contains(tableName) {
                return true
            }
            return false
        }
        set { }
    }
    
    private var entityClass: AnyClass
    private var tableName: String    
    private var persistenceServiceUtils: PersistenceServiceUtils
    
    init(entityClass: AnyClass) {
        self.entityClass = entityClass
        self.tableName = PersistenceHelper.shared.getTableNameFor(self.entityClass)
        self.rt = RTFactory.shared.creteEventHandlerForClass(entityClass: entityClass, tableName: tableName)
        persistenceServiceUtils = PersistenceServiceUtils(tableName: self.tableName)
    }
    
    public func mapToTable(tableName: String) {
        self.tableName = tableName
        let className = PersistenceHelper.shared.getClassNameWithoutModule(self.entityClass)
        Mappings.shared.mapTable(tableName: tableName, toClassNamed: className)
        persistenceServiceUtils = PersistenceServiceUtils(tableName: self.tableName)
    }
    
    public func mapColumn(columnName: String, toProperty: String) {
        let className = PersistenceHelper.shared.getClassNameWithoutModule(self.entityClass)
        Mappings.shared.mapColumn(columnName: columnName, toProperty: toProperty, ofClassNamed: className)
    }
    
    public func getObjectId(entity: Any) -> String? {
        return PersistenceHelper.shared.getObjectId(entity: entity)
    }
    
    public func save(entity: Any, responseHandler: ((Any) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        if PersistenceHelper.shared.getObjectId(entity: entity) != nil {
            update(entity: entity, responseHandler: responseHandler, errorHandler: errorHandler)
        }
        else {
            create(entity: entity, responseHandler: responseHandler, errorHandler: errorHandler)
        }
    }
    
    public func create(entity: Any, responseHandler: ((Any) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        let entityDictionary = PersistenceHelper.shared.entityToDictionary(entity: entity)
        persistenceServiceUtils.create(entity: entityDictionary, responseHandler: wrapResponse(responseHandler), errorHandler: errorHandler)
    }
    
    public func createBulk(entities: [Any], responseHandler: (([String]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        var entitiesDictionaries = [[String: Any]]()
        for entity in entities {
            entitiesDictionaries.append(PersistenceHelper.shared.entityToDictionary(entity: entity))
        }
        persistenceServiceUtils.createBulk(entities: entitiesDictionaries, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func update(entity: Any, responseHandler: ((Any) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        let entityDictionary = PersistenceHelper.shared.entityToDictionary(entity: entity)
        persistenceServiceUtils.update(entity: entityDictionary, responseHandler: wrapResponse(responseHandler), errorHandler: errorHandler)
    }
    
    public func updateBulk(whereClause: String?, changes: [String : Any], responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.updateBulk(whereClause: whereClause, changes: changes, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func removeById(objectId: String, responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.removeById(objectId: objectId, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func remove(entity: Any, responseHandler: ((Int) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        if let objectId = PersistenceHelper.shared.getObjectId(entity: entity) {
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
    
    public func find(responseHandler: (([Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        let wrappedBlock: ([[String: Any]]) -> () = { responseArray in
            var resultArray = [Any]()
            for responseObject in responseArray {
                let className = PersistenceHelper.shared.getClassNameWithoutModule(self.entityClass)
                if let resultObject = PersistenceHelper.shared.dictionaryToEntity(responseObject, className: className) {
                    resultArray.append(resultObject)
                }
            }
            responseHandler(resultArray)
        }
        persistenceServiceUtils.find(queryBuilder: nil, responseHandler: wrappedBlock, errorHandler: errorHandler)
    }
    
    public func find(queryBuilder: DataQueryBuilder, responseHandler: (([Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        let wrappedBlock: ([[String: Any]]) -> () = { responseArray in
            var resultArray = [Any]()
            for responseObject in responseArray {
                let className = PersistenceHelper.shared.getClassNameWithoutModule(self.entityClass)
                if let resultObject = PersistenceHelper.shared.dictionaryToEntity(responseObject, className: className) {
                    resultArray.append(resultObject)
                }
            }
            responseHandler(resultArray)
        }
        persistenceServiceUtils.find(queryBuilder: queryBuilder, responseHandler: wrappedBlock, errorHandler: errorHandler)
    }
    
    public func findFirst(responseHandler: ((Any) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.findFirstOrLastOrById(first: true, last: false, objectId: nil, queryBuilder: nil, responseHandler: wrapResponse(responseHandler), errorHandler: errorHandler)
    }
    
    public func findFirst(queryBuilder: DataQueryBuilder, responseHandler: ((Any) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.findFirstOrLastOrById(first: true, last: false, objectId: nil, queryBuilder: queryBuilder, responseHandler: wrapResponse(responseHandler), errorHandler: errorHandler)
    }
    
    public func findLast(responseHandler: ((Any) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.findFirstOrLastOrById(first: false, last: true, objectId: nil, queryBuilder: nil, responseHandler: wrapResponse(responseHandler), errorHandler: errorHandler)
    }
    
    public func findLast(queryBuilder: DataQueryBuilder, responseHandler: ((Any) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.findFirstOrLastOrById(first: false, last: true, objectId: nil, queryBuilder: queryBuilder, responseHandler: wrapResponse(responseHandler), errorHandler: errorHandler)
    }
    
    public func findById(objectId: String, responseHandler: ((Any) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.findFirstOrLastOrById(first: false, last: false, objectId: objectId, queryBuilder: nil, responseHandler: wrapResponse(responseHandler), errorHandler: errorHandler)
    }
    
    public func findById(objectId: String, queryBuilder: DataQueryBuilder, responseHandler: ((Any) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        persistenceServiceUtils.findFirstOrLastOrById(first: false, last: false, objectId: objectId, queryBuilder: queryBuilder, responseHandler: wrapResponse(responseHandler), errorHandler: errorHandler)
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
    
    public func loadRelations(objectId: String, queryBuilder: LoadRelationsQueryBuilder, responseHandler: (([Any]) -> Void)!, errorHandler: ((Fault) -> Void)!) {
        let wrappedBlock: ([Any]) -> () = { responseArray in
            var resultArray = [Any]()
            for responseObject in responseArray {
                if let dictResponse = responseObject as? [String : Any],
                    let relationType = queryBuilder.getRelationType() {
                    let className = PersistenceHelper.shared.getClassNameWithoutModule(relationType)
                    if let resultObject = PersistenceHelper.shared.dictionaryToEntity(dictResponse, className: className) {
                        resultArray.append(resultObject)
                    }
                }
                else {
                    resultArray.append(responseObject)
                }
            }
            responseHandler(resultArray)
        }
        persistenceServiceUtils.loadRelations(objectId: objectId, queryBuilder: queryBuilder, responseHandler: wrappedBlock, errorHandler: errorHandler)
    }
    
    private func wrapResponse(_ responseHandler: @escaping ((Any) -> Void)) -> (([String: Any]) -> ()) {
        let wrappedBlock: ([String: Any]) -> () = { responseDictionary in
            let className = PersistenceHelper.shared.getClassNameWithoutModule(self.entityClass)
            if let resultEntity = PersistenceHelper.shared.dictionaryToEntity(responseDictionary, className: className) {
                responseHandler(resultEntity)
            }
        }
        return wrappedBlock
    }
    
    // ****************************************************************************************
    
    public func enableOfflineAutoSync() {
        self.isOfflineAutoSyncEnabled = true
        OfflineSyncManager.shared.syncTables.append(tableName)
        OfflineSyncManager.shared.dontSyncTables.removeAll(where: {$0 == tableName})
    }
    
    public func disableOfflineAutoSync() {
        self.isOfflineAutoSyncEnabled = false
        OfflineSyncManager.shared.syncTables.removeAll(where: {$0 == tableName})
        OfflineSyncManager.shared.dontSyncTables.append(tableName)
    }
    
    public func initLocalDatabase(responseHandler: (() -> Void)!, errorHandler: ((Fault) -> Void)!) {
        PersistenceServiceUtilsLocal.shared.initLocalDatabase(tableName: tableName, whereClause: nil, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func initLocalDatabase(whereClause: String, responseHandler: (() -> Void)!, errorHandler: ((Fault) -> Void)!) {
        PersistenceServiceUtilsLocal.shared.initLocalDatabase(tableName: tableName, whereClause: whereClause, responseHandler: responseHandler, errorHandler: errorHandler)
    }
    
    public func clearLocalDatabase() {
        PersistenceServiceUtilsLocal.shared.clearLocalDatabase(tableName)
    }
    
    public func onSave(_ onSaveCallback: OnSave) {
        let wrappedSaveResponseHandler: (Any) -> () = { response in
            if let response = response as? [String : Any] {
                let className = PersistenceHelper.shared.getClassNameWithoutModule(self.entityClass)
                if let resultObject = PersistenceHelper.shared.dictionaryToEntity(response, className: className) {
                    onSaveCallback.saveResponseHandler?(resultObject)
                }
            }
        }
        OfflineSyncManager.shared.onSaveCallbacks[tableName] = OnSave(saveResponseHandler: wrappedSaveResponseHandler, errorHandler: onSaveCallback.errorHandler)
    }
    
    public func onRemove(_ onRemoveCallback: OnRemove) {
        let wrappedRemoveResponseHandler: (Any) -> () = { response in
            if let response = response as? [String : Any] {
                let className = PersistenceHelper.shared.getClassNameWithoutModule(self.entityClass)
                if let resultObject = PersistenceHelper.shared.dictionaryToEntity(response, className: className) {
                    onRemoveCallback.removeResponseHandler?(resultObject)
                }
            }
        }
        OfflineSyncManager.shared.onRemoveCallbacks[tableName] = OnRemove(removeResponseHandler: wrappedRemoveResponseHandler, errorHandler: onRemoveCallback.errorHandler)
    }
    
    public func saveEventually(entity: Any) {
        let entityDictionary = PersistenceHelper.shared.entityToDictionary(entity: entity)
        PersistenceServiceUtilsLocal.shared.saveEventually(tableName: tableName, entity: entityDictionary, callback: nil)
    }
    
    public func saveEventually(entity: Any, callback: OfflineAwareCallback) {
        let entityDictionary = PersistenceHelper.shared.entityToDictionary(entity: entity)
        let wrappedLocalResponseHandler: (Any) -> () = { response in
            if let response = response as? [String : Any] {
                let className = PersistenceHelper.shared.getClassNameWithoutModule(self.entityClass)
                if let resultObject = PersistenceHelper.shared.dictionaryToEntity(response, className: className) {
                    callback.localResponseHandler?(resultObject)
                }
            }
        }
        let wrappedRemoteResponseHandler: (Any) -> () = { response in
            if let response = response as? [String : Any] {
                let className = PersistenceHelper.shared.getClassNameWithoutModule(self.entityClass)
                if let resultObject = PersistenceHelper.shared.dictionaryToEntity(response, className: className) {
                    callback.remoteResponseHandler?(resultObject)
                }
            }
        }
        let wrappedCallback = OfflineAwareCallback(localResponseHandler: wrappedLocalResponseHandler, localErrorHandler: callback.localErrorHandler, remoteResponseHandler: wrappedRemoteResponseHandler, remoteErrorHandler: callback.remoteErrorHandler)
        PersistenceServiceUtilsLocal.shared.saveEventually(tableName: tableName, entity: entityDictionary, callback: wrappedCallback)
    }
    
    public func removeEventually(entity: Any) {
        let entityDictionary = PersistenceHelper.shared.entityToDictionary(entity: entity)
        PersistenceServiceUtilsLocal.shared.removeEventually(tableName: tableName, entity: entityDictionary, callback: nil)
    }
    
    public func removeEventually(entity: Any, callback: OfflineAwareCallback) {
        let entityDictionary = PersistenceHelper.shared.entityToDictionary(entity: entity)
        let wrappedLocalResponseHandler: (Any) -> () = { response in
            if let response = response as? [String : Any] {
                let className = PersistenceHelper.shared.getClassNameWithoutModule(self.entityClass)
                if let resultObject = PersistenceHelper.shared.dictionaryToEntity(response, className: className) {
                    callback.localResponseHandler?(resultObject)
                }
            }
        }
        let wrappedRemoteResponseHandler: (Any) -> () = { response in
            if let response = response as? [String : Any] {
                let className = PersistenceHelper.shared.getClassNameWithoutModule(self.entityClass)
                if let resultObject = PersistenceHelper.shared.dictionaryToEntity(response, className: className) {
                    callback.remoteResponseHandler?(resultObject)
                }
            }
        }
        let wrappedCallback = OfflineAwareCallback(localResponseHandler: wrappedLocalResponseHandler, localErrorHandler: callback.localErrorHandler, remoteResponseHandler: wrappedRemoteResponseHandler, remoteErrorHandler: callback.remoteErrorHandler)
        PersistenceServiceUtilsLocal.shared.removeEventually(tableName: tableName, entity: entityDictionary, callback: wrappedCallback)
    }
    
    // ****************************************************************************************
    
    public func getLocalCount() -> NSNumber {
        let count = LocalManager.shared.getNumberOfRecords(tableName, whereClause: "blPendingOperation!=2")
        if count is NSNumber {
            return count as! NSNumber
        }
        return 0
    }
    
    public func getLocalRecords() -> [[String : Any]] {
        if let localObjects = LocalManager.shared.select(tableName: tableName) as? [[String : Any]] {
            return localObjects
        }
        return [[String : Any]]()
    }
    
    public func checkIfTableExists() {
        print("Table \(tableName) exists: \(LocalManager.shared.tableExists(tableName))")
    }
    
    public func getTableNames() {
        print("All local tables: \(LocalManager.shared.getTables())")
    }
    
    public func getTableOperationsCount() -> Int {
        return OfflineSyncManager.shared.uow.operations.count
    }
}
