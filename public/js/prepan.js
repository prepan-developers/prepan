PrePAN      = {}
PrePAN.User = {};
PrePAN.Util = {
    formatDateTime : function (date) {
        var year   = date.getFullYear();
        var month  = date.getMonth()   <  9 ? "0" + (date.getMonth() + 1) : (date.getMonth() + 1);
        var day    = date.getDate()    < 10 ? "0" + date.getDate()    : date.getDate();
        var hour   = date.getHours()   < 10 ? "0" + date.getHours()   : date.getHours();
        var minute = date.getMinutes() < 10 ? "0" + date.getMinutes() : date.getMinutes();
        var second = date.getSeconds() < 10 ? "0" + date.getSeconds() : date.getSeconds();

        return [[year, month, day].join('-'), [hour, minute, second].join(':')].join(' ');
    }
};
  
PrePAN.Global = {
    init : function (args) {
        this.initHeader(args);
        this.initFirstGuide(args);
        this.initPrettyPrint(args);
        this.initDateTime(args);
    },

    initHeader : function (args) {
        var notify = $('#notify');
        $('#notify-button').click(function (event) {
            event.stopPropagation();

            var $this = $(this);
            if (!$this.data('loaded')) {
                $.ajax({
                    type     : 'POST',
                    url      :  '/api/notifications',
                    dataType : 'html',
                    data     : {
                        csrf_token : PrePAN.User.csrf_token
                    },
                    success: function (html) {
                        $this.html(0);
                        notify.append($(html));
                        $this.data('loaded', true);
                    }
                });
            }

            notify.fadeToggle();
        });

        var userMenu = $('#user-menu');
        $('#user-menu-button').click(function (event) {
            event.stopPropagation();
            userMenu.fadeToggle();
        });

        var signinMenu = $('#signin-menu');
        $('#signin-button').click(function (event) {
            event.stopPropagation();
            signinMenu.fadeToggle();
        });

        $(document.body).click(function (event) {
            notify.hide();
            userMenu.hide();
            signinMenu.hide();
        });
    },

    initFirstGuide : function (args) {
        if($.cookie('first-guide-close')){
            $('#first-guide').remove();
        }
        $('#first-guide-close').click(function(){
            $.cookie('first-guide-close', 1, { expires: 30 });
            $('#first-guide').css({'overflow':'hidden'}).animate({'height':0, 'margin':0},200);
        });
    },

    initPrettyPrint : function (args) {
        $('code').each(function () { $(this).addClass('prettyprint'); });
        prettyPrint()
    },

    initDateTime : function (args) {
        var date = new Date();
        var timezoneOffset = (new Date()).getTimezoneOffset();

        $('.timestamp').each(function () {
            var $this     = $(this);
            var timestamp = parseInt($this.attr('data-datetime-timestamp'));
            date.setTime((timestamp + (- timezoneOffset)) * 1000);
            string = PrePAN.Util.formatDateTime(date);
            $this.text(string);
        });
    }
};

PrePAN.Module = {
    init : function (args) {
        this.initComment();
        this.initVoteButton();
    },

    initComment : function () {
        $('.comment-delete').each(function () {
            var $this = $(this);
            var review_id = $this.attr('data-review-id');
            var container = $('#comment-' + review_id);

            $this.click(function () {
                if (window.confirm('Are you sure?')) {
                    $.ajax({
                        type : 'POST',
                        url  :  '/api/review.delete',
                        data : {
                            review_id  : review_id,
                            csrf_token : PrePAN.User.csrf_token
                        },
                        success: function (res) {
                            container.fadeOut('slow');
                        }
                    });
                }
            });
        });
    },

    initVoteButton : function () {
        var container = $('#feedback-prepan');
        var template  = $('#feedback-prepan-template');

        $('#feedback-prepan-button')
            .each(function () {
                var $this = $(this);

                $.ajax({
                    type : 'GET',
                    url  :  '/api/module.vote',
                    data : {
                        module_id  : PrePAN.Module.id,
                    },
                    success: function (res) {
                        var error = res.already_voted ?
                            "You've already voted this module" :
                            res.login_required ?
                            "You need sign up/in to mark as good to this module" :
                            undefined;
                        
                        if (error) {
                            $this.unbind('click');
                            $this.click(function () {
                                alert(error);
                            });
                        }
                        if (res.status == 'ok') {
                            if (!res.users) return;

                            for (var i = 0, length = res.users.length; i < length; i++) {
                                template.tmpl(res.users[i]).appendTo(container);
                            }
                        }
                        else {
                            alert(res.message);
                        }
                    },
                    error: function (error) {
                        alert(error);
                    }
                });
            })
            .click(function () {
                var $this = $(this);

                $.ajax({
                    type : 'POST',
                    url  :  '/api/module.vote',
                    data : {
                        module_id  : PrePAN.Module.id,
                        csrf_token : PrePAN.User.csrf_token
                    },
                    success: function (res) {
                        if (res.status == 'ok') {
                            var user = res.user;
                            template.tmpl(user).appendTo(container);
                            $this.unbind('click');
                        }
                        else {
                            alert(res.message);
                        }
                    },
                    error: function (error) {
                        alert(error);
                    }
                });
            });
    }
};

PrePAN.Preview = {};
PrePAN.Preview.Description = {
    init : function (args) {
        $('.description-preview').toggle(function () {
            PrePAN.Preview.Description.preview(args.token);
        }, function () {
            PrePAN.Preview.Description.edit();
        });

        // remove disable on submit
        var $description = $('#description');
        $('.submit input').click(function () {
            $description.removeAttr('disabled');
        });
    },
    preview : function (token) {
        var $description = $('#description');
        var markdown     = $description.val();

        $description.attr('disabled', 'disabled');
        $.ajax({
            type : 'POST',
            url : '/api/markdown2html',
            data : {
                markdown   : markdown,
                csrf_token : token
            },
            success : function (res) {
                var $container = $('<div id="module-description" class="preview"></div>');
                $container.append(res);
                $container.insertAfter($description);
                $('.description-preview').val('edit');
                $description.hide();
            }
        });
    },
    edit : function () {
        var $description = $('#description');
        var $container   = $('#module-description');

        $description.removeAttr('disabled');
        $('.description-preview').val('preview');
        $description.show();
        $container.remove();
    }
};
