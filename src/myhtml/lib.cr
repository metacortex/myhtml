module Myhtml
  # cd src/ext && make
  @[Link(ldflags: "#{__DIR__}/../ext/myhtml-c/lib/libmyhtml_static.a")]
  lib Lib
    type MyhtmlT = Void*
    type MyhtmlTreeT = Void*
    type MyhtmlTreeNodeT = Void*
    type MyhtmlTreeAttrT = Void*
    type MyhtmlTagIndexT = Void*
    type MyhtmlTagIndexNodeT = Void*
    alias MyhtmlTagIdT = MyhtmlTags

    struct MyhtmlVersion
      major : Int32
      minor : Int32
      patch : Int32
    end

    fun create = myhtml_create : MyhtmlT*
    fun init = myhtml_init(myhtml : MyhtmlT*, opt : MyhtmlOptions, thread_count : LibC::SizeT, queue_size : LibC::SizeT) : MyhtmlStatus

    fun tree_create = myhtml_tree_create : MyhtmlTreeT*
    fun tree_init = myhtml_tree_init(tree : MyhtmlTreeT*, myhtml : MyhtmlT*) : MyhtmlStatus

    fun tree_destroy = myhtml_tree_destroy(tree : MyhtmlTreeT*) : MyhtmlTreeT*
    fun destroy = myhtml_destroy(myhtml : MyhtmlT*) : MyhtmlT*

    fun tree_parse_flags_set = myhtml_tree_parse_flags_set(tree : MyhtmlTreeT*, parse_flags : MyhtmlTreeParseFlags)

    fun parse = myhtml_parse(tree : MyhtmlTreeT*, encoding : MyhtmlEncodingList, html : UInt8*, html_size : LibC::SizeT) : MyhtmlStatus

    fun encoding_detect_and_cut_bom = myhtml_encoding_detect_and_cut_bom(text : UInt8*, length : LibC::SizeT, encoding : MyhtmlEncodingList*, new_text : UInt8**, new_size : LibC::SizeT*) : Bool
    fun version = myhtml_version : MyhtmlVersion

    # ======= TREE ===========

    fun tree_get_document = myhtml_tree_get_document(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun tree_get_node_html = myhtml_tree_get_node_html(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun tree_get_node_head = myhtml_tree_get_node_head(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*
    fun tree_get_node_body = myhtml_tree_get_node_body(tree : MyhtmlTreeT*) : MyhtmlTreeNodeT*

    fun node_child = myhtml_node_child(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_next = myhtml_node_next(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_parent = myhtml_node_parent(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_prev = myhtml_node_prev(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_last_child = myhtml_node_last_child(node : MyhtmlTreeNodeT*) : MyhtmlTreeNodeT*
    fun node_remove = myhtml_node_remove(tree : MyhtmlTreeT*, node : MyhtmlTreeNodeT*)

    fun tag_name_by_id = myhtml_tag_name_by_id(tree : MyhtmlTreeT*, tag_id : MyhtmlTagIdT, length : LibC::SizeT*) : UInt8*
    fun node_tag_id = myhtml_node_tag_id(node : MyhtmlTreeNodeT*) : MyhtmlTagIdT
    fun node_text = myhtml_node_text(node : MyhtmlTreeNodeT*, length : LibC::SizeT*) : UInt8*

    fun node_attribute_first = myhtml_node_attribute_first(node : MyhtmlTreeNodeT*) : MyhtmlTreeAttrT*
    fun attribute_key = myhtml_attribute_key(attr : MyhtmlTreeAttrT*, length : LibC::SizeT*) : UInt8*
    fun attribute_value = myhtml_attribute_value(attr : MyhtmlTreeAttrT*, length : LibC::SizeT*) : UInt8*
    fun attribute_next = myhtml_attribute_next(attr : MyhtmlTreeAttrT*) : MyhtmlTreeAttrT*

    fun tree_get_tag_index = myhtml_tree_get_tag_index(tree : MyhtmlTreeT*) : MyhtmlTagIndexT*
    fun tag_index_first = myhtml_tag_index_first(tag_index : MyhtmlTagIndexT*, tag_id : MyhtmlTagIdT) : MyhtmlTagIndexNodeT*
    fun tag_index_entry_count = myhtml_tag_index_entry_count(tag_index : MyhtmlTagIndexT*, tag_id : MyhtmlTagIdT) : LibC::SizeT
    fun tag_index_tree_node = myhtml_tag_index_tree_node(index_node : MyhtmlTagIndexNodeT*) : MyhtmlTreeNodeT*
    fun tag_index_next = myhtml_tag_index_next(index_node : MyhtmlTagIndexNodeT*) : MyhtmlTagIndexNodeT*

    # ===== SAX ========

    type MyhtmlTokenNodeT = Void*
    type MyhtmlCallbackTokenF = MyhtmlTreeT*, MyhtmlTokenNodeT*, Void* -> Void*
    type MyhtmlIncomingBufferT = Void*

    struct MyhtmlPositionT
      start : LibC::SizeT
      length : LibC::SizeT
    end

    fun callback_before_token_done_set = myhtml_callback_before_token_done_set(tree : MyhtmlTreeT*, func : MyhtmlCallbackTokenF, ctx : Void*)
    fun callback_after_token_done_set = myhtml_callback_after_token_done_set(tree : MyhtmlTreeT*, func : MyhtmlCallbackTokenF, ctx : Void*)
    fun tree_incoming_buffer_first = myhtml_tree_incoming_buffer_first(tree : MyhtmlTreeT*) : MyhtmlIncomingBufferT*

    fun token_node_raw_pasition = myhtml_token_node_raw_pasition(token : MyhtmlTokenNodeT*) : MyhtmlPositionT
    fun token_node_element_pasition = myhtml_token_node_element_pasition(token : MyhtmlTokenNodeT*) : MyhtmlPositionT
    fun token_node_attribute_first = myhtml_token_node_attribute_first(token : MyhtmlTokenNodeT*) : MyhtmlTreeAttrT*
    fun token_node_tag_id = myhtml_token_node_tag_id(token : MyhtmlTokenNodeT*) : MyhtmlTagIdT
    fun token_node_text = myhtml_token_node_text(node : MyhtmlTokenNodeT*, length : LibC::SizeT*) : UInt8*
    fun token_node_is_close_self = myhtml_token_node_is_close_self(token : MyhtmlTokenNodeT*) : Bool
    fun token_node_is_close = myhtml_token_node_is_close(token : MyhtmlTokenNodeT*) : Bool

    fun incoming_buffer_find_by_position = myhtml_incoming_buffer_find_by_position(inc_buf : MyhtmlIncomingBufferT*, begin : LibC::SizeT) : MyhtmlIncomingBufferT*
    fun incoming_buffer_offset = myhtml_incoming_buffer_offset(inc_buf : MyhtmlIncomingBufferT*) : LibC::SizeT
    fun incoming_buffer_data = myhtml_incoming_buffer_data(inc_buf : MyhtmlIncomingBufferT*) : UInt8*

    fun attribute_key_raw_position = myhtml_attribute_key_raw_position(attr : MyhtmlTreeAttrT*) : MyhtmlPositionT
    fun attribute_value_raw_position = myhtml_attribute_value_raw_position(attr : MyhtmlTreeAttrT*) : MyhtmlPositionT
  end
end
